{ ... }:
{
  users.users.root = {
    hashedPassword = "$6$NdVVcYQySNPcQRSt$r9EKoXQ3WpHkj.Fk60nlRhcAcbDfuDCFBuuE2Npq8JRynkT5MQw0L2EFMOUbGPu470p6aJZNDDkR7i6iGsC.20";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFj+oDZwuwmlh7dx9LYlSSMBZ29ejGJ5BFVD4ILx6aN home@michael-graversen.dk"
    ];
  };

  security.sudo.execWheelOnly = true;

  home-manager.users.root = {
    home.username = "root";
    home.homeDirectory = "/root";
  };
}
