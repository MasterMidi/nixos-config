# https://github.com/timewave-computer/flake-parts-addons/blob/84c6ec3eaa6ff1ebf87dc68c29da9b8fc7ec1b58/deploy-rs.nix
# SPDX-FileCopyrightText: 2024 Sefa Eyeoglu <contact@scrumplex.net>
# SPDX-License-Identifier: MPL-2.0

{ ... }:
rec {
  imports = [
    flake.flakeModules.deploy-rs
  ];
  flake.flakeModules.deploy-rs =
    {
      config,
      self,
      inputs,
      lib,
      ...
    }:
    let
      cfg = config.deploy;

      settings = {
        generic = {
          options = {
            sshUser = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };
            user = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };
            sshOpts = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
            };
            fastConnection = lib.mkOption {
              type = with lib.types; nullOr bool;
              default = null;
            };
            autoRollback = lib.mkOption {
              type = with lib.types; nullOr bool;
              default = null;
            };
            confirmTimeout = lib.mkOption {
              type = with lib.types; nullOr int;
              default = null;
            };
            activationTimeout = lib.mkOption {
              type = with lib.types; nullOr int;
              default = null;
            };
            tempPath = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };
            magicRollback = lib.mkOption {
              type = with lib.types; nullOr bool;
              default = null;
            };
            sudo = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };
            remoteBuild = lib.mkOption {
              type = with lib.types; nullOr bool;
              default = null;
            };
            interactiveSudo = lib.mkOption {
              type = with lib.types; nullOr bool;
              default = null;
            };
          };
        };
        profile = {
          options = {
            path = lib.mkOption {
              type = lib.types.package;
            };
            profilePath = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };
          };
        };
        node = {
          options = {
            hostname = lib.mkOption {
              type = lib.types.str;
            };
            profilesOrder = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
            };
            profiles = lib.mkOption {
              type = lib.types.attrsOf profileModule;
            };
          };
        };

        nodes = {
          options.nodes = lib.mkOption {
            type = lib.types.attrsOf nodeModule;
          };
        };
      };

      profileModule = lib.types.submoduleWith {
        modules = [
          settings.generic
          settings.profile
        ];
      };

      nodeModule = lib.types.submoduleWith {
        modules = [
          settings.generic
          settings.node
        ];
      };

      rootModule = lib.types.submoduleWith {
        modules = [
          settings.generic
          settings.nodes
          (
            { config, ... }:
            {
              options.input = lib.mkOption {
                type = lib.types.package;
              };
              options.lib = lib.mkOption {
                type = lib.types.raw;
              };
              config.input = lib.mkIf (inputs ? deploy-rs || inputs ? deploy) (
                lib.mkDefault (inputs.deploy-rs or inputs.deploy)
              );
              config.lib = lib.mkDefault config.input.lib;
            }
          )
        ];
      };

      keepAttrs = attrs: names: lib.filterAttrs (name: _: lib.elem name names) attrs;

      keepOptions =
        attrs: opts: keepAttrs attrs (lib.attrNames (settings.generic.options // opts.options));

      filterNullRecursive = lib.filterAttrsRecursive (_: v: v != null);

    in
    {
      options.deploy = lib.mkOption {
        type = rootModule;
      };
      config = {
        flake.deploy = filterNullRecursive (
          (keepOptions cfg settings.nodes)
          // {
            nodes = lib.mapAttrs (
              _: node:
              (keepOptions node settings.node)
              // {
                profiles = lib.mapAttrs (_: profile: keepOptions profile settings.profile) node.profiles;
              }
            ) cfg.nodes;
          }
        );
        perSystem =
          { system, ... }:
          {
            checks = lib.mkIf (cfg.lib ? ${system}) (cfg.lib.${system}.deployChecks self.deploy);
          };
      };
    };
}
