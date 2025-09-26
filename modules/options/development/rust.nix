# Save this as development/rust/default.nix in your NixOS configuration directory
# https://github.com/oxalica/rust-overlay
{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.development.rust;

  # Define options for the JetBrains Rust IDE (RustRover)
  rustRoverOptions = {
    options = {
      enable = lib.mkEnableOption "Enables JetBrains RustRover IDE";
      # Keep addHyprlandCompat as it's specific to JetBrains IDEs like RustRover
      addHyprlandCompat = lib.mkEnableOption "Adds Hyprland config rules for better compatibility with JetBrains IDEs (like RustRover)";
    };
  };

  # --- Rust Package Selection Logic ---
  # Determines which rust-bin package to install based on version or channel
  rustPackage =
    if cfg.version != null
    then # If a specific version is set, use that
      pkgs.rust-bin.${cfg.version}.${cfg.profile}
    else # Otherwise, use the latest from the specified channel
      pkgs.rust-bin.${cfg.channel}.latest.${cfg.profile};
in {
  options.development.rust = {
    enable = lib.mkEnableOption "Add development tools for rust";

    # Renamed from 'rider' to 'rustRover' for clarity and consistency with package
    rustRover = lib.mkOption {
      type = lib.types.submodule rustRoverOptions;
      default = {};
      description = "Options for configuring the JetBrains RustRover IDE.";
    };

    version = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "When set (e.g., '1.70.0'), will ignore 'channel' and use this specific version of the Rust toolchain from rust-overlay.";
    };

    channel = lib.mkOption {
      type = lib.types.enum ["stable" "beta" "nightly"];
      default = "stable";
      description = "Specifies the Rust release channel to use if 'version' is not set.";
    };

    profile = lib.mkOption {
      type = lib.types.enum ["default" "minimal"];
      default = "default";
      description = "Specifies the installation profile for the Rust toolchain.";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [inputs.rust-overlay.overlays.default];

    environment.systemPackages = with pkgs; [
      # Install the selected Rust toolchain globally
      rustPackage

      # Conditionally install RustRover if enabled
      (lib.mkIf cfg.rustRover.enable jetbrains.rust-rover)

      # Add other common Rust tools if desired, e.g.:
      # rustfmt # Code formatter
      # clippy # Linter
      # cargo-expand # Macro expansion
      # cargo-audit # Dependency security audit
      # ... add more as needed
    ];

    # --- Conditional Hyprland Configuration ---
    # Only apply Hyprland rules if RustRover and its Hyprland compatibility are enabled
    home-manager.users.michael.wayland.windowManager.hyprland.settings.windowrulev2 = lib.mkIf (cfg.rustRover.enable && cfg.rustRover.addHyprlandCompat) [
      # Fix jetbrains IDE's tooltip hover issues (apply to any jetbrains-.* class)
      "float,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
      "nofocus,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
    ];

    # patch global rustrover settings for the std lib location of rust
    # https://intellij-support.jetbrains.com/hc/en-us/articles/206544519-Directories-used-by-the-IDE-to-store-settings-caches-plugins-and-logs
    # This often requires setting environment variables or creating config files
    # in the user's home directory. A simple way might be using home-manager options
    # or environment.sessionVariables if applicable, but it's IDE version dependent.
    # Example (might not work depending on IDE version/config):
    # environment.sessionVariables = lib.mkIf cfg.rustRover.enable {
    #   # Placeholder - consult JetBrains docs or community for correct variable
    #   IDEA_JDK = "${pkgs.jdk}";
    #   # May need to point to the Nix store path of the rust stdlib
    #   # RUST_SRC_PATH = "${rustPackage}/lib/rustlib/src/rust"; # Example path structure
    # };

    # Plugin support with this flake?
    # https://github.com/theCapypara/nix-jetbrains-plugins
    # If you want to manage JetBrains plugins via Nix, you would typically
    # integrate that flake or similar methods, likely within your home-manager
    # configuration for the specific user.
  };
}
