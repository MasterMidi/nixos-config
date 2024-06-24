{...}: {
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
    };
  };
}
