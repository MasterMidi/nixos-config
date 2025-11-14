# https://github.com/timewave-computer/flake-parts-addons/blob/84c6ec3eaa6ff1ebf87dc68c29da9b8fc7ec1b58/deploy-rs.nix
# SPDX-FileCopyrightText: 2024 Sefa Eyeoglu <contact@scrumplex.net>
# SPDX-License-Identifier: MPL-2.0

{
  config,
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (inputs) deploy-rs;

  cfg = config.deploy;

  settings = {
    generic = {
      options = {
        sshUser = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        user = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        sshOpts = mkOption {
          type = with types; listOf str;
          default = [ ];
        };
        fastConnection = mkOption {
          type = with types; nullOr bool;
          default = null;
        };
        autoRollback = mkOption {
          type = with types; nullOr bool;
          default = null;
        };
        confirmTimeout = mkOption {
          type = with types; nullOr int;
          default = null;
        };
        activationTimeout = mkOption {
          type = with types; nullOr int;
          default = null;
        };
        tempPath = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        magicRollback = mkOption {
          type = with types; nullOr bool;
          default = null;
        };
        sudo = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        remoteBuild = mkOption {
          type = with types; nullOr bool;
          default = null;
        };
        interactiveSudo = mkOption {
          type = with types; nullOr bool;
          default = null;
        };
      };
    };
    profile = {
      options = {
        path = mkOption {
          type = types.package;
        };
        profilePath = mkOption {
          type = with types; nullOr str;
          default = null;
        };
      };
    };
    node = {
      options = {
        hostname = mkOption {
          type = types.str;
        };
        profilesOrder = mkOption {
          type = with types; listOf str;
          default = [ ];
        };
        profiles = mkOption {
          type = types.attrsOf profileModule;
        };
      };
    };

    nodes = {
      options.nodes = mkOption {
        type = types.attrsOf nodeModule;
      };
    };
  };

  profileModule = types.submoduleWith {
    modules = [
      settings.generic
      settings.profile
    ];
  };

  nodeModule = types.submoduleWith {
    modules = [
      settings.generic
      settings.node
    ];
  };

  rootModule = types.submoduleWith {
    modules = [
      settings.generic
      settings.nodes
      (
        { config, ... }:
        {
          options.input = mkOption {
            type = types.package;
          };
          options.lib = mkOption {
            type = types.raw;
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
  options.deploy = mkOption {
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
}
