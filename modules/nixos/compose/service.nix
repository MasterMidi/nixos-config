{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.virtualisation.oci-containers.compose;
  backend = config.virtualisation.oci-containers.backend;

  isContainerNetwork = network: lib.hasPrefix "container:" network;

  extractContainerName =
    network:
    let
      containerName = lib.removePrefix "container:" network;
    in
    if lib.match ".*-.*" containerName != null then
      lib.last (lib.splitString "-" containerName)
    else
      containerName;

  getNetworkDependencies =
    networks: map extractContainerName (lib.filter isContainerNetwork networks);

  concatPorts =
    port:
    [
      (toString port.host)
      (lib.optionalString (port.internal != null) ":${toString port.internal}")
      (lib.optionalString (port.protocol != null) "/${port.protocol}")
    ]
    |> lib.strings.concatStrings;

  processContainerNetwork =
    composeName: network:
    let
      containerName = extractContainerName network;
      fullContainerName =
        if lib.hasPrefix "${composeName}-" containerName then
          containerName
        else
          "${composeName}-${containerName}";
    in
    "container:${fullContainerName}";

  makeNetworkOptions =
    composeName: containerConfig:
    if containerConfig.networking.useHostNetwork then
      [ "--network=host" ]
    else
      let
        networks =
          if containerConfig.networking.networks != [ ] then
            containerConfig.networking.networks
          else
            [ "default" ];

        regularNetworks = lib.filter (n: !isContainerNetwork n) networks;
        containerNetworks = lib.filter isContainerNetwork networks;

        mappedNetworks = map (network: "${composeName}-${network}") regularNetworks;

        aliasOptions = lib.flatten (
          map (
            network: map (alias: "--network-alias=${alias}") containerConfig.networking.aliases
          ) mappedNetworks
        );

        networkOptions = map (network: "--network=${network}") mappedNetworks;

        containerNetworkOptions = map (
          network: "--network=${processContainerNetwork composeName network}"
        ) containerNetworks;
      in
      containerNetworkOptions ++ networkOptions ++ aliasOptions;

  # Helper function to split volume string into source and target
  splitVolume =
    volume:
    let
      parts = volume |> lib.splitString ":";
    in
    {
      source = lib.head parts;
      target = if lib.length parts > 1 then lib.elemAt parts 1 else lib.head parts;
      mode = if lib.length parts > 2 then lib.elemAt parts 2 else "rw";
    };
in
{
  config = lib.mkIf (cfg != { }) {
    virtualisation.oci-containers.containers = lib.mkMerge (
      lib.mapAttrsToList (
        composeName: composeConfig:
        lib.mapAttrs' (
          containerName: containerConfig:
          lib.nameValuePair "${composeName}-${containerName}" {
            image = containerConfig.image;
            environment = containerConfig.environment;
            volumes = containerConfig.volumes;
            ports =
              containerConfig.ports
              ++ (containerConfig.networking.ports |> lib.mapAttrsToList (_: p: p |> concatPorts));
            log-driver = "journald";
            user = containerConfig.user; # "${containerConfig.user}${lib.optional (containerConfig.group != null) ":${containerConfig.group}"}";
            dependsOn =
              (containerConfig.dependsOn ++ getNetworkDependencies containerConfig.networking.networks)
              |> lib.unique
              |> map (dep: "${composeName}-${dep}");
            cmd = containerConfig.commands;
            extraOptions =
              (makeNetworkOptions composeName containerConfig)
              ++ (lib.optional (
                containerConfig.autoUpdate != null
              ) "--label=io.containers.autoupdate=${containerConfig.autoUpdate}")
              ++ (map (label: "--label=${label}") containerConfig.labels)
              ++ (map (ip: "--ip=${ip}") containerConfig.networking.ips)
              ++ (map (cap: "--cap-add=${cap}") containerConfig.capabilities)
              ++ (map (dev: "--device=${dev}") containerConfig.devices)
              ++ (map (env: "--secret=${composeName}-${containerName}-${env},type=env,target=${env}") (
                builtins.attrNames containerConfig.secrets.env
              ))
              ++ (lib.optional (containerConfig.healthcheck.cmd != null)
                "--health-cmd=\"${containerConfig.healthcheck.cmd |> lib.concatStringsSep " "}\""
              )
              ++ (lib.optional (
                containerConfig.healthcheck.startPeriod != null
              ) "--health-start-period=${containerConfig.healthcheck.startPeriod}")
              ++ (lib.optional (
                containerConfig.healthcheck.interval != null
              ) "--health-interval=${containerConfig.healthcheck.interval}")
              ++ (lib.optional (
                containerConfig.healthcheck.timeout != null
              ) "--health-timeout=${containerConfig.healthcheck.timeout}")
              ++ (lib.optional (
                containerConfig.healthcheck.retries != null
              ) "--health-retries=${toString containerConfig.healthcheck.retries}")
              ++ containerConfig.extraOptions;
          }
        ) composeConfig.containers
      ) cfg
    );

    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (
        composeName: composeConfig:
        lib.mkMerge [
          (lib.mapAttrs' (
            networkName: networkOptions:
            lib.nameValuePair "${backend}-${composeName}-network-${networkName}" {
              path = [ pkgs.podman ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStop = "${backend} network rm -f ${composeName}-${networkName}";
              };
              script =
                "${backend} network inspect ${composeName}-${networkName} || ${backend} network create ${composeName}-${networkName} "
                + builtins.concatStringsSep " " (
                  [
                    "--driver=${networkOptions.driver}"
                    (lib.optionalString networkOptions.internal "--internal")
                  ]
                  ++ (map (subnet: "--subnet=${subnet}") networkOptions.subnets)
                  ++ (map (gateway: "--gateway=${gateway}") networkOptions.gateways)
                );
              partOf = [ "${backend}-compose-${composeName}-root.target" ];
              wantedBy = [ "${backend}-compose-${composeName}-root.target" ];
            }
          ) composeConfig.networks)

          (
            # modify containers
            lib.mapAttrs' (
              containerName: containerConfig:
              lib.nameValuePair "${backend}-${composeName}-${containerName}" {
                serviceConfig.Restart = lib.mkOverride 500 "always";
                unitConfig.RequiresMountsFor = map (volume: (splitVolume volume).source) containerConfig.volumes;
                after = [ "${backend}-compose-${composeName}-root.target" ];
                requires = [ "${backend}-compose-${composeName}-root.target" ];
                partOf = [ "${backend}-compose-${composeName}-root.target" ];
                wantedBy = [ "${backend}-compose-${composeName}-root.target" ];
              }
            ) composeConfig.containers
          )

          (lib.mkMerge (
            lib.mapAttrsToList (
              containerName: containerConfig:
              lib.mapAttrs' (
                secretName: secretValue:
                lib.nameValuePair "${backend}-${composeName}-${containerName}-secret-${secretName}" {
                  path = [ pkgs.podman ];
                  serviceConfig = {
                    Type = "oneshot";
                    RemainAfterExit = true;
                    ExecStop = "${backend} secret rm ${composeName}-${containerName}-${secretName}";
                  };
                  script = "${backend} secret create --driver=${secretValue.driver} ${lib.optionalString secretValue.replace "--replace"} ${
                    lib.optionalString (secretValue.labels != null)
                      "--label=${
                        (builtins.concatStringsSep "," (lib.mapAttrsToList (key: val: "${key}=${val}") secretValue.labels))
                      }"
                  } ${composeName}-${containerName}-${secretName} ${secretValue.path}";
                  partOf = [ "${backend}-${composeName}-${containerName}.service" ];
                  wantedBy = [ "${backend}-${composeName}-${containerName}.service" ];
                  before = [ "${backend}-${composeName}-${containerName}.service" ];
                }
              ) containerConfig.secrets.env
            ) composeConfig.containers
          ))
        ]
      ) cfg
    );

    # Add the root target for the compose service
    systemd.targets = lib.mkMerge (
      lib.mapAttrsToList (composeName: composeConfig: {
        "${backend}-compose-${composeName}-root" = {
          unitConfig = {
            Description = "Root target for ${composeName} compose service";
          };
          wantedBy = [ "multi-user.target" ];
        };
      }) cfg
    );
  };
}
