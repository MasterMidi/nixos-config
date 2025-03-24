{config, ...}: {
  # sops configuration
  sops = {
    age = {
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt"; # must have no password!
      # generateKey = true; # This will generate a new key if the key specified above does not exist
    };
    defaultSopsFile = ./secrets.sops.yaml;
    secrets = {
      SSH_KEY = {};
      SSH_KEY_PUB = {};
    };
  };
}
