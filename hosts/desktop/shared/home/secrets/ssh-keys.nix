{config, ...}: {
  # add users ssh key
  systemd.user.tmpfiles.rules = [
    "L+ '${config.home.homeDirectory}/.ssh/id_ed25519' - - - - ${config.sops.secrets.SSH_KEY.path}"
    "L+ '${config.home.homeDirectory}/.ssh/id_ed25519.pub' - - - - ${config.sops.secrets.SSH_KEY_PUB.path}"
  ];
}
