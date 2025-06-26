{ lib, config, ... }:
let
  backend = config.virtualisation.oci-containers.backend;

  # Secrets configuration options
  secretsOptions = lib.types.submodule {
    options = {
      path = lib.mkOption {
        type = lib.types.str;
        description = "Path to the secret value.";
      };
      driver = lib.mkOption {
        type = lib.types.enum [
          "file"
          "pass"
          "shell"
        ];
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

  submoduleWithArgs =
    { module, args }:
    lib.types.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      specialArgs = args;
      modules = lib.toList module;
    };
in
{
  options.virtualisation.oci-containers.compose = lib.mkOption {
    description = "Compose-like configuration for OCI containers.";
    example = '''';
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            enable = lib.mkEnableOption "Enable the compose service";
            containers = lib.mkOption {
              description = "Containers defined in this compose service.";
              default = { };
              type = lib.types.attrsOf (submoduleWithArgs {
                args = {
                  composeName = name;
                };
                module =
                  { name, composeName, ... }:
                  {
                    options = rec {
                      unitName = lib.mkOption {
                        type = lib.types.str;
                        default = "${backend}-${containerName.default}.service";
                        description = "The name of the generated systemd unit.";
                        readOnly = true;
                      };
                      containerName = lib.mkOption {
                        type = lib.types.str;
                        default = "${composeName}-${name}";
                        description = "The name of the container started by ${backend}.";
                        readOnly = true;
                      };
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
                        default = { };
                        description = "Environment variables for the container.";
                      };
                      volumes = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ ];
                        description = "Volumes to mount in the container.";
                      };
                      ports = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ ];
                        description = "Ports to expose from the container.";
                      };
                      extraOptions = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ ];
                        description = "Additional options for the container.";
                      };
                      dependsOn = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ ];
                        description = "List of services this container depends on. Automatically includes containers referenced in networking.networks.";
                      };
                      networking = lib.mkOption {
                        type = lib.types.submodule {
                          options = {
                            networks = lib.mkOption {
                              type = lib.types.listOf lib.types.str;
                              default = [ ];
                              description = "Networks that the container will be part of. Can be named networks or 'container:container-name'";
                            };
                            aliases = lib.mkOption {
                              type = lib.types.listOf lib.types.str;
                              default = [ ];
                              description = "Network aliases for the container (only applies to named networks, not container networks).";
                            };
                            useHostNetwork = lib.mkOption {
                              type = lib.types.bool;
                              default = false;
                              description = "Use host network instead of container networking. When enabled, network aliases and compose-prefixed network names are ignored.";
                            };
                            ports = lib.mkOption {
                              type = lib.types.attrsOf (
                                lib.types.submodule {
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
                                      type = lib.types.nullOr (
                                        lib.types.enum [
                                          "tcp"
                                          "udp"
                                        ]
                                      );
                                      default = null;
                                      description = "The protocol to use.";
                                    };
                                    # protocols = lib.mkOption {
                                    # 	type = lib.types.listOf (lib.types.enum ["tcp" "udp"]);
                                    # 	default = null;
                                    # 	description = "The protocol to use.";
                                    # };
                                  };
                                }
                              );
                              default = { };
                              description = "Network ports to bind to.";
                            };
                            ips = lib.mkOption {
                              type = lib.types.listOf lib.types.str;
                              default = [ ];
                              description = "IP addresses to assign to the container.";
                            };
                          };
                        };
                        default = { };
                        description = "Network configuration for the container.";
                      };
                      autoUpdate = lib.mkOption {
                        type = lib.types.nullOr (
                          lib.types.enum [
                            "registry"
                            "local"
                          ]
                        );
                        default = null;
                        example = "registry";
                        description = "Automatically update the container image.";
                      };
                      capabilities = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ ];
                        description = "List of capabilities to add to the container.";
                      };
                      devices = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ ];
                        description = "List of devices to add to the container.";
                      };
                      secrets = lib.mkOption {
                        type = lib.types.submodule {
                          options = {
                            env = lib.mkOption {
                              type = lib.types.attrsOf secretsOptions;
                              default = { };
                              description = "Environment variable name to use for the secret.";
                            };
                            mount = lib.mkOption {
                              type = lib.types.attrsOf secretsOptions;
                              default = { };
                              description = "Path to mount the secret in the container.";
                            };
                          };
                        };
                        default = { };
                        description = "Secrets to be used in the container.";
                      };
                      healthcheck = lib.mkOption {
                        type = lib.types.submodule {
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
                        default = { };
                        description = "Healthcheck configuration for the container.";
                      };
                      commands = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ ];
                        description = "Commands to run on the container entrypoint.";
                      };
                      labels = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [ ];
                        description = "Labels to apply to the container.";
                      };
                    };
                  };
              });
            };
            networks = lib.mkOption {
              type = lib.types.attrsOf (
                lib.types.submodule {
                  options = {
                    driver = lib.mkOption {
                      type = lib.types.enum [
                        "bridge"
                        "macvlan"
                        "ipvlan"
                      ];
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
                      default = [ ];
                      description = "Set network-scoped DNS resolver/nameserver for containers in this network.";
                    };
                    disableDns = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = "Disable the DNS resolver for this network.";
                    };
                    subnets = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      default = [ ];
                      description = "";
                    };
                    gateways = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      default = [ ];
                      description = "";
                    };
                  };
                }
              );
              default = [ "default" ];
              description = "Networks to create for this compose service.";
            };
          };
        }
      )
    );
  };
}
