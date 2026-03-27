{ ... }:
rec {
  imports = [
    flake.flakeModules.nix-builder
  ];
  flake.flakeModules.nix-builder =
    {
      config,
      self,
      lib,
      ...
    }:
    let
      builderModule = lib.types.submodule {
        options = {
          hostName = lib.mkOption { type = lib.types.str; };
          system = lib.mkOption { type = lib.types.str; };
          systems = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          maxJobs = lib.mkOption {
            type = lib.types.int;
            default = 1;
          };
          speedFactor = lib.mkOption {
            type = lib.types.int;
            default = 1;
          };
          supportedFeatures = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
          };
          hostPublicKey = lib.mkOption { type = lib.types.str; };
        };
      };

      cfg = config.builder;
    in
    {
      options.builder = lib.mkOption {
        type = lib.types.attrsOf builderModule;
        default = { };
        description = "Definitions for remote Nix builders.";
      };

      config = {
        flake.builders = cfg;

        flake.nixosModules.nix-builder =
          { config, ... }:
          let
            # Find if the current machine is defined as a builder in the flake
            maybeMe = self.builders.${config.networking.hostName} or null;
            isBuilder = lib.hasAttr config.networking.hostName self.builders;
          in
          {
            # 1. CLIENT LOGIC: Use other machines as builders
            nix = {
              distributedBuilds = true;
              buildMachines = lib.pipe self.builders [
                (lib.attrValues)
                (lib.filter (b: b.hostName != config.networking.hostName))
                (map (b: {
                  inherit (b)
                    hostName
                    system
                    systems
                    maxJobs
                    speedFactor
                    supportedFeatures
                    ;
                  protocol = "ssh-ng";
                  sshUser = "nix-builder";
                  sshKey = "/root/.ssh/nix-builder-key";
                }))
              ];
            };

            # 2. HOST LOGIC: Configure this machine to BE a builder
            users.users.nix-builder = lib.mkIf isBuilder {
              isNormalUser = true;
              description = "Dedicated user for Nix remote builds";
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/wwcgUh2vV59HySfZKgRDxI69eHHIrOAEVyWZNxvfY nix-remote-builder"
              ];
            };

            nix.settings.trusted-users = lib.mkIf isBuilder [ "nix-builder" ];

            # --- NEW: AUTOMATIC BINFMT EMULATION ---
            # If this machine is a builder, find systems in its list that aren't native
            boot.binfmt.emulatedSystems = lib.mkIf isBuilder (
              builtins.filter (s: s != maybeMe.system) maybeMe.systems
            );

            # 3. GLOBAL LOGIC: Known hosts for all nodes
            programs.ssh.knownHosts = lib.mapAttrs (_: b: {
              publicKey = b.hostPublicKey;
            }) self.builders;
          };
      };
    };
}
