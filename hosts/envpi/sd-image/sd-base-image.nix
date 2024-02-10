{...}: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  users.mutableUsers = true;
  users.users.pi = {
    isNormalUser = true;
    description = "Raspberry Pi 3B";
    extraGroups = ["networkmanager" "wheel"];
    hashedPassword = "$y$j9T$gGYH3.06eDEcKfalPhHPb.$ioKMb3Nw3jtFPvlrYpwkaH7HR4V2.o5mHgq.b9lmx30";
  };
  users.users.root = {
    hashedPassword = "$y$j9T$gGYH3.06eDEcKfalPhHPb.$ioKMb3Nw3jtFPvlrYpwkaH7HR4V2.o5mHgq.b9lmx30";
  };
  system.stateVersion = "23.11";
  # Do not compress the image as we want to use it straight away
  sdImage.compressImage = false;
  # put your own configuration here, for example ssh keys:
  # Enable networking
  networking.networkmanager.enable = false;
  networking.wireless.enable = true;
  networking.wireless.networks = {
    "Asus RT-AX86U" = {
      psk = "3zyn2dY&Gp";
      #pskRaw="f5e51f4b158ceb87a44bc82d2ade090948de95c90d59689d3fe8c7427cb877d2";
    };
  };
  networking.hostName = "envpi";
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true; # set to true if you want the password prompt
}
