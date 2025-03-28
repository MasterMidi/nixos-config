{config, ...}: {
  sops.secrets = {
    SOPS_AGE_KEY = {
      sopsFile = ./secrets.sops.yaml;
    };
  };
}