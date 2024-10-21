{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.virtualisation.oci-containers.compose;
  backend = config.virtualisation.oci-containers.backend;

  # Helper function to split volume string into source and target
  splitVolume = volume: let
    parts = splitString ":" volume;
  in {
    source = head parts;
    target =
      if length parts > 1
      then elemAt parts 1
      else head parts;
    mode =
      if length parts > 2
      then elemAt parts 2
      else "rw";
  };

  # Helper function to get UID and GID from PUID and PGID environment variables
  getUidGid = environment: let
    uid = environment.PUID or environment.UID or "0";
    gid = environment.PGID or environment.GID or "0";
  in {inherit uid gid;};

  # Container options
  containerOptions = {
    name,
    config,
    ...
  }: {
    options = {
      image = mkOption {
        type = types.str;
        description = "The container image to use.";
      };
      environment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables for the container.";
      };
      volumes = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Volumes to mount in the container.";
      };
      ports = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Ports to expose from the container.";
      };
      extraOptions = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional options for the container.";
      };
      dependsOn = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of services this container depends on.";
      };
      networks = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Network(s) that the container will be part of.";
      };
    };
  };

  # Compose options
  composeOptions = {
    name,
    config,
    ...
  }: {
    options = {
      enable = mkEnableOption "Enable the compose service";
      containers = mkOption {
        type = types.attrsOf (types.submodule containerOptions);
        default = {};
        description = "Containers defined in this compose service.";
      };
      networks = mkOption {
        type = types.listOf types.str;
        default = ["default"];
        description = "Networks to create for this compose service.";
      };
    };
  };
in {
  options.virtualisation.oci-containers.compose = mkOption {
    type = types.attrsOf (types.submodule composeOptions);
    default = {};
    description = "Compose-like configuration for OCI containers.";
  };

  config = mkIf (cfg != {}) {
    # define containers
    virtualisation.oci-containers.containers = mkMerge (
      mapAttrsToList
      (
        composeName: composeConfig:
          mapAttrs' (
            containerName: containerConfig:
              nameValuePair "${composeName}-${containerName}" {
                image = containerConfig.image;
                environment = containerConfig.environment;
                volumes = containerConfig.volumes;
                ports = containerConfig.ports;
                log-driver = "journald";
                dependsOn = map (dep: "${composeName}-${dep}") containerConfig.dependsOn;
                extraOptions =
                  [
                    # "--network-alias=${containerName}"
                  ]
                  ++ containerConfig.extraOptions
                  ++ optional (containerConfig.networks != []) "--network=${head containerConfig.networks}";
              }
          )
          composeConfig.containers
      )
      cfg
    );

    # Extend container configurations and add network services for containers
    systemd.services = mkMerge (
      mapAttrsToList
      (
        composeName: composeConfig:
          mapAttrs' (
            containerName: containerConfig:
              nameValuePair "${backend}-${composeName}-${containerName}" {
                serviceConfig.Restart = lib.mkOverride 500 "always"; # always restart the service
                unitConfig.RequiresMountsFor = map (volume: (splitVolume volume).source) containerConfig.volumes; # require mounts to exist for volumes
                after = ["${backend}-compose-${composeName}-root.target"];
                requires = ["${backend}-compose-${composeName}-root.target"];
                partOf = ["${backend}-compose-${composeName}-root.target"];
                wantedBy = ["${backend}-compose-${composeName}-root.target"];
              }
          )
          composeConfig.containers
          // mapAttrs' (
            networkName: _:
              nameValuePair "${backend}-network-${composeName}-${networkName}" {
                path = [pkgs.podman];
                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                  ExecStop = "${backend} network rm -f ${composeName}-${networkName}";
                };
                script = ''
                  ${backend} network inspect ${composeName}-${networkName} || ${backend} network create ${composeName}-${networkName}
                '';
                partOf = ["${backend}-compose-${composeName}-root.target"];
                wantedBy = ["${backend}-compose-${composeName}-root.target"];
              }
          ) (genAttrs composeConfig.networks (name: null))
      )
      cfg
    );

    # Root services
    # When started, these will automatically create all resources and start
    # the containers in the compose. When stopped, these will teardown all resources.
    systemd.targets = lib.mkMerge (
      lib.mapAttrsToList (composeName: composeConfig: {
        "${backend}-compose-${composeName}-root" = {
          unitConfig = {
            Description = "Root target for ${composeName} compose service";
          };
          wantedBy = ["multi-user.target"];
        };
      })
      cfg
    );

    # Add tmpfiles rules for volume creation
    # systemd.tmpfiles.rules = flatten (
    #   mapAttrsToList
    #   (
    #     composeName: composeConfig:
    #       mapAttrsToList (
    #         containerName: containerConfig:
    #           map (
    #             volume: let
    #               parsed = splitVolume volume;
    #               ids = getUidGid containerConfig.environment;
    #             in "d ${parsed.source} 0770 ${ids.uid} ${ids.gid} - -"
    #           )
    #           containerConfig.volumes
    #       )
    #       composeConfig.containers
    #   )
    #   cfg
    # );
  };
}
