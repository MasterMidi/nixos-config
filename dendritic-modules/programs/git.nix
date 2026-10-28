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
    { ... }:
    {
      imports = [ self.homeModules.git ];

      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
    };
}
