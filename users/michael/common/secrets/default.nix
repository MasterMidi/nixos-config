{ config, inputs, ... }:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    secrets = {
      SSH_KEY = {
        mode = "0600";
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        sopsFile = ./secrets.yaml;
      };
      SSH_KEY_PUB = {
        mode = "0600";
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        sopsFile = ./secrets.yaml;
      };
    };
  };
}
