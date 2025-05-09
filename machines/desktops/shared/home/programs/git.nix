{config, ...}: {
  programs.git = {
    enable = true;
    userName = "Michael Andreas Graversen";
    userEmail = "home@michael-graversen.dk";
    lfs.enable = true;
    extraConfig = {
      credential = {
        credentialStore = "secretservice";
      };
      pull.rebase = false;
      gpg.format = "ssh";
      commit.gpgsign = true;
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
  };
}
