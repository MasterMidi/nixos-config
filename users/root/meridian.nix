{ inputs, ... }:
{
  imports = [
    ./common.nix
  ];

  home-manager.users.root = {
    home.stateVersion = "23.11";
  };
}
