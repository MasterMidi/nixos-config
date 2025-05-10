{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.development.android;

  # Define options for the Flutter setup
  flutterOptions = {
    enable = lib.mkEnableOption "Enables Flutter SDK and related tools (Dart)";
    # You could add more Flutter-specific options here later if needed,
    # e.g., specific Flutter channel or version.
  };
in {
  options.development.android = {
    enable = lib.mkEnableOption "Add development tools for Android";

    # Option to enable the Flutter environment
    flutter = lib.mkOption {
      type = lib.types.submodule flutterOptions;
      default = {};
      description = "Options for configuring the Flutter development environment.";
    };

    # You could add more options here for other Android tools or configurations,
    # e.g., specific Android SDK versions, platform tools, build tools, etc.
  };

  config = lib.mkIf cfg.enable {
    # Enable Android Debug Bridge (ADB) program
    programs.adb.enable = true;

    # Add user 'michael' to necessary groups for hardware access (KVM, ADB, UDEV)
    # Note: Replace 'michael' with your actual username if different.
    users.users.michael.extraGroups = ["kvm" "adbusers" "udev"];

    # Install core Android and potentially Flutter packages
    environment.systemPackages = with pkgs; [
      # Android Studio IDE
      android-studio

      # Conditionally install Flutter and Dart if the flutter option is enabled
      (lib.mkIf cfg.flutter.enable flutter)
      (lib.mkIf cfg.flutter.enable dart)

      # Add other common Android development tools if desired, e.g.:
      # android-tools # Includes adb, fastboot, etc. (programs.adb.enable handles adb)
      # android-sdk.platform-tools # Specific platform tools
      # android-sdk.build-tools # Specific build tools
      # ... add more as needed
    ];

    # Automatically accept the Android SDK license
    # This is necessary for Android Studio and SDK components to function.
    nixpkgs.config = {
      android_sdk.accept_license = true;
    };

    # Potential fixes/configurations for Android/Flutter:
    # - Environment variables: Sometimes specific environment variables are needed
    #   for the Android SDK or Flutter to be found correctly by other tools or IDEs.
    #   environment.sessionVariables = { ... };
    # - PATH configuration: Ensure necessary binaries are in the user's PATH.
    #   Nix usually handles this well, but double-check if tools aren't found.
    # - Specific SDK components: You might need to install specific SDK components
    #   (like system images for emulators, specific API levels) via `android-sdk`
    #   or within Android Studio itself.
  };
}
