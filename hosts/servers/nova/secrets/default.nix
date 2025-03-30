{...}: {
  sops.secrets = {
    SOPS_AGE_KEY = {
      sopsFile = ./secrets.sops.yaml;
    };
    PANGOLING_ADMIN_PASSWORD = {
      sopsFile = ./secrets.sops.yaml;
    };
  };
}
