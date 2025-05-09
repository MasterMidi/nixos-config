{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [inputs.lollypops.nixosModules.lollypops];

  lollypops.deployment = {
    local-evaluation = lib.mkDefault true;

    # Where on the remote the configuration (system flake) is placed
    config-dir = lib.mkDefault "/var/src/lollypops";

    # SSH connection parameters
    ssh.host = lib.mkDefault config.networking.hostName;
    ssh.user = lib.mkDefault "root";
    ssh.command = lib.mkDefault "ssh";
    ssh.opts = [];

    # sudo options
    sudo.enable = lib.mkDefault true;
    sudo.command = lib.mkDefault "sudo";
    sudo.opts = [];
  };

  systemd.tmpfiles.rules = ["d ${config.lollypops.deployment.config-dir} 1777 ${config.lollypops.deployment.ssh.user} ${config.lollypops.deployment.ssh.user} -"];

  # Add the my public SSH key to the authorized_keys of the root user
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFj+oDZwuwmlh7dx9LYlSSMBZ29ejGJ5BFVD4ILx6aN home@michael-graversen.dk"
  ];

  # Allow to ssh into deployment user (root)
  # TODO: create a dedicated deployment user
  services.openssh.settings.PermitRootLogin = "yes";
}
