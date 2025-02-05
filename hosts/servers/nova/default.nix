{
  modulesPath,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFj+oDZwuwmlh7dx9LYlSSMBZ29ejGJ5BFVD4ILx6aN home@michael-graversen.dk"
  ];

  system.stateVersion = "24.11";

  lollypops.deployment = {
    local-evaluation = true;
    # Where on the remote the configuration (system flake) is placed
    config-dir = "/var/src/lollypops";

    # SSH connection parameters
    # ssh.host = "${config.networking.hostName}.local";
    ssh.host = "138.199.154.23";
    ssh.user = "root";
    ssh.command = "ssh";
    ssh.opts = [];

    # sudo options
    sudo.enable = true;
    sudo.command = "sudo";
    sudo.opts = [];
  };
}
