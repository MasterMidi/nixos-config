{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Michael Andreas Graversen";
    userEmail = "work@michael-graversen.dk";
    lfs.enable = true;
    extraConfig = {
      credential = {
        credentialStore = "secretservice";
        # helper = "${pkgs.git-credential-manager}/lib/git-credential-manager/git-credential-manager";
        # helper = "${pkgs.nur.repos.utybo.git-credential-manager}/bin/git-credential-manager"; # TODO: don't use nur repo
      };
      pull.rebase = false;
    };
  };
}
