{ self, ... }:
{
  flake.homeModules.git =
    { config, ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Michael Andreas Graversen";
            email = "home@michael-graversen.dk";
          };
          credential = {
            credentialStore = "secretservice";
          };
          pull.rebase = false;
          gpg.format = "ssh";
          commit.gpgsign = true;
          user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        };
        lfs.enable = true;
      };
    };

  flake.homeModules.git-hyperion =
    { lib, ... }:
    {
      imports = [ self.homeModules.git ];

      # Hyperion is the WSL environment on the work laptop: use the work
      # GitHub account (mgr-solita) identity instead of the private one.
      programs.git.settings.user = {
        name = lib.mkForce "Michael Andreas Graversen";
        email = lib.mkForce "mgr@solita.dk";
      };

      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
    };
}
