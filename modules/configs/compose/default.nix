{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.virtualisation.oci-containers.compose;
  backend = config.virtualisation.oci-containers.backend;

  # Helper function to split volume string into source and target
  splitVolume = volume: let
    parts = volume |> lib.splitString ":";
  in {
    source = lib.head parts;
    target =
      if lib.length parts > 1
      then lib.elemAt parts 1
      else lib.head parts;
    mode =
      if lib.length parts > 2
      then lib.elemAt parts 2
      else "rw";
  };

  # Rest of the helper functions remain the same
  isContainerNetwork = network: lib.hasPrefix "container:" network;
  extractContainerName = network: let
    containerName = lib.removePrefix "container:" network;
  in
    if lib.match ".*-.*" containerName != null
    then lib.last (lib.splitString "-" containerName)
    else containerName;

  processContainerNetwork = composeName: network: let
    containerName = extractContainerName network;
    fullContainerName =
      if lib.hasPrefix "${composeName}-" containerName
      then containerName
      else "${composeName}-${containerName}";
  in "container:${fullContainerName}";

  getNetworkDependencies = networks:
    map extractContainerName (lib.filter isContainerNetwork networks);

  # Updated makeNetworkOptions to handle host networking
  makeNetworkOptions = composeName: containerConfig:
    if containerConfig.networking.useHostNetwork
    then ["--network=host"]
    else let
      networks =
        if containerConfig.networking.networks != []
        then containerConfig.networking.networks
        else ["default"];

      regularNetworks = lib.filter (n: !isContainerNetwork n) networks;
      containerNetworks = lib.filter isContainerNetwork networks;

      mappedNetworks = map (network: "${composeName}-${network}") regularNetworks;

      aliasOptions = lib.flatten (map (
          network:
            map (alias: "--network-alias=${alias}") containerConfig.networking.aliases
        )
        mappedNetworks);

      networkOptions = map (network: "--network=${network}") mappedNetworks;

      containerNetworkOptions =
        map (
          network: "--network=${processContainerNetwork composeName network}"
        )
        containerNetworks;
    in
      containerNetworkOptions ++ networkOptions ++ aliasOptions;

	# function to split port into host:internal
	# splitPort = port: let
	# 	parts = port
	# 		|> lib.splitString ":"
	# 		|> map (x: lib.splitString "/" x)
	# 		|> lib.flatten;
	# in containerPortOptions {
	# 	host = lib.head parts;
	# 	internal = if lib.length parts > 1
  #     then lib.elemAt parts 2
  #     else null;
	# 	protocol = if lib.length parts > 2
  #     then lib.elemAt parts 2
  #     else null;
	# };

	concatPorts = port: [(toString  port.host) (lib.optionalString (port.internal != null) ":${toString port.internal}") (lib.optionalString (port.protocol != null) "/${port.protocol}") ]
                |> lib.strings.concatStrings;

  # -- New configuration options --- #

  # Network configuration options
  containerNetworkingOptions = lib.types.submodule {
    options = {
      networks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Networks that the container will be part of. Can be named networks or 'container:container-name'";
      };
      aliases = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Network aliases for the container (only applies to named networks, not container networks).";
      };
      useHostNetwork = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use host network instead of container networking. When enabled, network aliases and compose-prefixed network names are ignored.";
      };
      ports = lib.mkOption {
        type = lib.types.attrsOf containerPortOptions;
        default = {};
        description = "Network ports to bind to.";
      };
			ips = lib.mkOption {
				type = lib.types.listOf lib.types.str;
				default = [];
				description = "IP addresses to assign to the container.";
			};
    };
  };

  # Secrets configuration options for containers
  containerSecretsOptions = lib.types.submodule {
    options = {
      env = lib.mkOption {
        type = lib.types.attrsOf secretsOptions;
        default = {};
        description = "Environment variable name to use for the secret.";
      };
      mount = lib.mkOption {
        type = lib.types.attrsOf secretsOptions;
        default = {};
        description = "Path to mount the secret in the container.";
      };
    };
  };

  containerHealthcheckOptions = lib.types.submodule {
    options = {
      cmd = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        description = "The command to perform.";
      };
      startPeriod = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The start period for the check.";
      };
      interval = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The interval between checks.";
      };
      timeout = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The timeout for the check.";
      };
      retries = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "The number of retries.";
      };
    };
  };

  # Secrets configuration options
  secretsOptions = lib.types.submodule {
    options = {
      path = lib.mkOption {
        type = lib.types.str;
        description = "Path to the secret value.";
      };
      driver = lib.mkOption {
        type = lib.types.enum ["file" "pass" "shell"];
        default = "file";
        description = "The secret driver";
      };
      replace = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Replace the secret if it already exists.";
      };
      labels = lib.mkOption {
        type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
        default = null;
        description = "Labels to apply to the secret.";
      };
    };
  };

	containerPortOptions = lib.types.submodule {
		options = {
			host = lib.mkOption {
				type = lib.types.int;
				description = "The host port to bind to.";
			};
			internal = lib.mkOption {
				type = lib.types.int;
				description = "The internal port to bind to.";
			};
			protocol = lib.mkOption {
				type = lib.types.nullOr (lib.types.enum ["tcp" "udp"]);
				default = null;
				description = "The protocol to use.";
			};
		};
	};

  # Container options
  containerOptions = {
    options = {
      user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The user to run the container as.";
      };
      group = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The group to run the container as.";
      };
      image = lib.mkOption {
        type = lib.types.str;
        description = "The container image to use.";
      };
      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Environment variables for the container.";
      };
      volumes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Volumes to mount in the container.";
      };
      ports = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Ports to expose from the container.";
      };
      extraOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional options for the container.";
      };
      dependsOn = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of services this container depends on. Automatically includes containers referenced in networking.networks.";
      };
      networking = lib.mkOption {
        type = containerNetworkingOptions;
        default = {};
        description = "Network configuration for the container.";
      };
      autoUpdate = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum ["registry" "local"]);
        default = null;
        example = "registry";
        description = "Automatically update the container image.";
      };
      capabilities = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of capabilities to add to the container.";
      };
      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of devices to add to the container.";
      };
      secrets = lib.mkOption {
        type = containerSecretsOptions;
        default = {};
        description = "Secrets to be used in the container.";
      };
      healthcheck = lib.mkOption {
        type = containerHealthcheckOptions;
        default = {};
        description = "Healthcheck configuration for the container.";
      };
      commands = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Commands to run on the container entrypoint.";
      };
      labels = lib.mkOption {
				type = lib.types.listOf lib.types.str;
				default = [];
				description = "Labels to apply to the container.";
			};
    };
  };

	composeNetworkOptions = lib.types.submodule {
		options = {
			driver = lib.mkOption {
				type = lib.types.enum ["bridge" "macvlan" "ipvlan"];
				default = "bridge";
				description = "The network driver to use.";
			};
			internal = lib.mkOption {
				type = lib.types.bool;
				default = false;
				description = "Whether the network is internal.";
			};
			labels = lib.mkOption {
				type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
				default = null;
				description = "Labels to apply to the network.";
			};
			options = lib.mkOption {
				type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
				default = null;
				description = "Additional options for the network.";
			};
			ipv6 = lib.mkOption {
				type = lib.types.bool;
				default = false;
				description = "Whether to enable IPv6 on the network.";
			};
			dns = lib.mkOption {
				type = lib.types.listOf lib.types.str;
				default = [];
				description = "Set network-scoped DNS resolver/nameserver for containers in this network.";
			};
			disableDns = lib.mkOption {
				type = lib.types.bool;
				default = false;
				description = "Disable the DNS resolver for this network.";
			};
      subnets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "";
      };
      gateways = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "";
      };
		};
	};

  # Rest of the options and configuration remain the same
  composeOptions = {
    options = {
      enable = lib.mkEnableOption "Enable the compose service";
      containers = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule containerOptions);
        default = {};
        description = "Containers defined in this compose service.";
      };
      networks = lib.mkOption {
        type = lib.types.attrsOf composeNetworkOptions;
        default = ["default"];
        description = "Networks to create for this compose service.";
      };
    };
  };
in {
  options.virtualisation.oci-containers.compose = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule composeOptions);
    default = {};
    description = "Compose-like configuration for OCI containers.";
  };

  config = lib.mkIf (cfg != {}) {
    virtualisation.oci-containers.containers = lib.mkMerge (
      lib.mapAttrsToList
      (
        composeName: composeConfig:
          lib.mapAttrs' (
            containerName: containerConfig:
              lib.nameValuePair "${composeName}-${containerName}" {
                image = containerConfig.image;
                environment = containerConfig.environment;
                volumes = containerConfig.volumes;
                ports = containerConfig.ports ++ (containerConfig.networking.ports |> lib.mapAttrsToList (_: p: p |> concatPorts));
                log-driver = "journald";
                user = containerConfig.user; #"${containerConfig.user}${lib.optional (containerConfig.group != null) ":${containerConfig.group}"}";
                dependsOn = (containerConfig.dependsOn ++ getNetworkDependencies containerConfig.networking.networks)
															|> lib.unique
															|> map (dep: "${composeName}-${dep}");
                cmd = containerConfig.commands;
                extraOptions =
                  (makeNetworkOptions composeName containerConfig)
                  ++ (lib.optional (containerConfig.autoUpdate != null) "--label=io.containers.autoupdate=${containerConfig.autoUpdate}")
                  ++ (map (label: "--label=${label}") containerConfig.labels)
									++ (map (ip: "--ip=${ip}") containerConfig.networking.ips)
                  ++ (map (cap: "--cap-add=${cap}") containerConfig.capabilities)
                  ++ (map (dev: "--device=${dev}") containerConfig.devices)
                  ++ (map (env: "--secret=${composeName}-${containerName}-${env},type=env,target=${env}") (builtins.attrNames containerConfig.secrets.env))
                  ++ (lib.optional (containerConfig.healthcheck.cmd != null) "--health-cmd=\"${containerConfig.healthcheck.cmd
												|> lib.concatStringsSep " "}\"")
									++ (lib.optional (containerConfig.healthcheck.startPeriod != null) "--health-start-period=${containerConfig.healthcheck.startPeriod}")
									++ (lib.optional (containerConfig.healthcheck.interval != null) "--health-interval=${containerConfig.healthcheck.interval}")
									++ (lib.optional (containerConfig.healthcheck.timeout != null) "--health-timeout=${containerConfig.healthcheck.timeout}")
									++ (lib.optional (containerConfig.healthcheck.retries != null) "--health-retries=${toString containerConfig.healthcheck.retries}")
                  ++ containerConfig.extraOptions;
              }
          )
          composeConfig.containers
      )
      cfg
    );

    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (
        composeName: composeConfig:
          lib.mkMerge [
            (
              lib.mapAttrs' (
                networkName: networkOptions:
                  lib.nameValuePair "${backend}-${composeName}-network-${networkName}" {
                    path = [pkgs.podman];
                    serviceConfig = {
                      Type = "oneshot";
                      RemainAfterExit = true;
                      ExecStop = "${backend} network rm -f ${composeName}-${networkName}";
                    };
                    script = "${backend} network inspect ${composeName}-${networkName} || ${backend} network create ${composeName}-${networkName} " + builtins.concatStringsSep " " ([
											"--driver=${networkOptions.driver}"
											(lib.optionalString networkOptions.internal "--internal")
										]
                    ++ (map (subnet: "--subnet=${subnet}") networkOptions.subnets)
                    ++ (map (gateway: "--gateway=${gateway}") networkOptions.gateways));
                    partOf = ["${backend}-compose-${composeName}-root.target"];
                    wantedBy = ["${backend}-compose-${composeName}-root.target"];
                  }
              )
							composeConfig.networks
            )

            (
              # modify containers
              lib.mapAttrs' (
                containerName: containerConfig:
                  lib.nameValuePair "${backend}-${composeName}-${containerName}" {
                    serviceConfig.Restart = lib.mkOverride 500 "always";
                    unitConfig.RequiresMountsFor = map (volume: (splitVolume volume).source) containerConfig.volumes;
                    after = ["${backend}-compose-${composeName}-root.target"];
                    requires = ["${backend}-compose-${composeName}-root.target"];
                    partOf = ["${backend}-compose-${composeName}-root.target"];
                    wantedBy = ["${backend}-compose-${composeName}-root.target"];
                  }
              )
              composeConfig.containers
            )

            (
              lib.mkMerge (
                lib.mapAttrsToList (
                  containerName: containerConfig:
                    lib.mapAttrs' (
                      secretName: secretValue:
                        lib.nameValuePair "${backend}-${composeName}-${containerName}-secret-${secretName}" {
                          path = [pkgs.podman];
                          serviceConfig = {
                            Type = "oneshot";
                            RemainAfterExit = true;
                            ExecStop = "${backend} secret rm ${composeName}-${containerName}-${secretName}";
                          };
                          script = "${backend} secret create --driver=${secretValue.driver} ${lib.optionalString secretValue.replace "--replace"} ${lib.optionalString (secretValue.labels != null) "--label=${(builtins.concatStringsSep "," (lib.mapAttrsToList (key: val: "${key}=${val}") secretValue.labels))}"} ${composeName}-${containerName}-${secretName} ${secretValue.path}";
                          partOf = ["${backend}-${composeName}-${containerName}.service"];
                          wantedBy = ["${backend}-${composeName}-${containerName}.service"];
                          before = ["${backend}-${composeName}-${containerName}.service"];
                        }
                    )
                    containerConfig.secrets.env
                )
                composeConfig.containers
              )
            )
          ]
      )
      cfg
    );

    # Add the root target for the compose service
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
  };
}
