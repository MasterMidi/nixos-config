{pkgs, ...}: {
  programs.adb.enable = true;

  users.users.michael.extraGroups = ["kvm" "adbusers" "udev"];

  environment.systemPackages = with pkgs; [
    androidStudioPackages.stable
    flutter
    dart
  ];

  nixpkgs.config = {
    android_sdk.accept_license = true;
  };
}
