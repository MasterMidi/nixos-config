# https://github.com/oxalica/rust-overlay
{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.development.rust;

  riderOptions = {
    enable = lib.mkEnableOption "Enables Rider as an IDE";
    addHyprlandCompat = lib.mkEnableOption "Adds to your hyprland config to make it work better with rider";
  };
in {
  options.development.rust = {
    enable = lib.mkEnableOption "Add development tools for rust";
    rider = lib.mkOption {
      type = lib.types.submodule riderOptions;
      default = {};
    };
    version = {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "When set, will ignore channel and use this specific version";
    };
    channel = lib.mkOption {
      type = lib.types.enum ["stable" "beta" "nightly"];
      default = "stable";
      description = "";
    };
    profile = lib.mkOption {
      type = lib.types.enum ["default" "minimal"];
      default = "default";
    };
  };

  config = lib.mkIf cfg.enable {
    imports = [
      inputs.rust-overlay.overlays.default
    ];

    environment.systemPackages = with pkgs; [
      jetbrains.rust-rover
      rust-bin.${cfg.channel}.latest.${cfg.profile}
    ];

    home-manager.users.michael.wayland.windowManager.hyprland.settings.windowrulev2 = [
      # Fix jetbrains IDE's tooltip hover issues
      "float,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
      "nofocus,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
    ];

    # patch global rustrover settings for the std lib location of rust
    # https://intellij-support.jetbrains.com/hc/en-us/articles/206544519-Directories-used-by-the-IDE-to-store-settings-caches-plugins-and-logs

    # Plugin support with this flake?
    # https://github.com/theCapypara/nix-jetbrains-plugins
  };
}
