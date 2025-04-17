{ ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  users.mutableUsers = true;
  users.users.raspi = {
    isNormalUser = true;
    description = "Raspberry Pi 3B";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "$y$j9T$gGYH3.06eDEcKfalPhHPb.$ioKMb3Nw3jtFPvlrYpwkaH7HR4V2.o5mHgq.b9lmx30";
  };
  users.users.root = {
    hashedPassword = "$y$j9T$gGYH3.06eDEcKfalPhHPb.$ioKMb3Nw3jtFPvlrYpwkaH7HR4V2.o5mHgq.b9lmx30";
  };
  system.stateVersion = "23.11";
  # Do not compress the image as we want to use it straight away
  sdImage.compressImage = false;
  # put your own configuration here, for example ssh keys:
  networking.networkmanager.enable = true;
  networking.hostName = "pisces";
  services.openssh.enable = true;

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true; # set to true if you want the password prompt
}
