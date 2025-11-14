{ ... }:
{
  imports = [
    ./common.nix
  ];

  home-manager.users.michael = {
    imports = [
      ./programs/bashmount.nix
      ./programs/fzf.nix
      ./programs/git.nix
      ./programs/lazygit.nix
      ./programs/ripgrep.nix
    ];
  };
}
