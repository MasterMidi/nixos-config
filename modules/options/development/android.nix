# TODO: update this to an option and import in default.nix
{pkgs, ...}: {
  programs.adb.enable = true;

  users.users.michael.extraGroups = ["kvm" "adbusers" "udev"];

  environment.systemPackages = with pkgs; [
    android-studio
    flutter
    dart
  ];

  nixpkgs.config = {
    android_sdk.accept_license = true;
  };
}
