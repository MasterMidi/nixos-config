{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.development.dotnet;

  # Define options for the JetBrains Rider IDE
  riderOptions = {
    options = {
      enable = lib.mkEnableOption "Enables JetBrains Rider IDE";
      # Adds to your hyprland config to make it work better with Rider and other JetBrains IDEs
      addHyprlandCompat = lib.mkEnableOption "Adds Hyprland config rules for better compatibility with JetBrains IDEs (like Rider)";
    };
  };

  # --- .NET SDK Package Selection Logic ---
  # Determines which dotnetCorePackages SDK to install based on the sdkVersion option
  # Defaults to a recent stable version if null, but it's better practice
  # to explicitly set the version you want.
  dotnetSdkPackage = with pkgs.dotnetCorePackages;
    if cfg.sdkVersion != null
    then # If a specific version is set, use that (e.g., "sdk_9_0")
      lib.getAttr cfg.sdkVersion pkgs.dotnetCorePackages
    else # Otherwise, you might fall back to a default or require the user to set it.
      # Requiring the user to set it is often safer for SDKs to avoid unexpected upgrades.
      # For this example, we'll default to a common recent one, but you can change this.
      sdk_9_0; # Defaulting to 9.0 as per your current setup
in {
  options.development.dotnet = {
    enable = lib.mkEnableOption "Add development tools for .NET";

    rider = lib.mkOption {
      type = lib.types.submodule riderOptions;
      default = {};
      description = "Options for configuring the JetBrains Rider IDE.";
    };

    sdkVersion = lib.mkOption {
      type = lib.types.nullOr lib.types.str; # Take a package directly instead
      default = null;
      description = ''
        Specifies the .NET SDK version to install from pkgs.dotnetCorePackages.
        Set to a string like "sdk_6_0", "sdk_7_0", "sdk_8_0", "sdk_9_0", etc.
        If null, a default version (currently 9.0) will be used.
      '';
    };

    # You could add more options here for other .NET tools if needed,
    # e.g., global tools, specific NuGet configurations, etc.
  };

  config = lib.mkIf cfg.enable {
    # No need for rust-overlay equivalent here, dotnet SDKs are in nixpkgs

    environment.systemPackages = with pkgs; [
      # Install the selected .NET SDK globally
      dotnetSdkPackage

      # Conditionally install Rider if enabled
      (lib.mkIf cfg.rider.enable jetbrains.rider)

      # Add other common .NET tools if desired, e.g.:
      # dotnet-format # Code formatter
      # nuget # NuGet package manager (often included with SDK)
      # ... add more as needed
    ];

    # --- Conditional Hyprland Configuration ---
    # Only apply Hyprland rules if Rider and its Hyprland compatibility are enabled
    # Note: These rules apply to any jetbrains-.* class, which is suitable for Rider too.
    home-manager.users.michael.wayland.windowManager.hyprland.settings.windowrulev2 = lib.mkIf (cfg.rider.enable && cfg.rider.addHyprlandCompat) [
      # Fix jetbrains IDE's tooltip hover issues
      "float,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
      "nofocus,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
    ];
  };
}
