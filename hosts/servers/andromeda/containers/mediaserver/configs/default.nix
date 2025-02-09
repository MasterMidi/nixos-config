{config,...}:{
  sops.secrets = {
    WIREGUARD_AIRVPN_CONF = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      format = "binary";
      sopsFile = ./wireguard.airvpn.conf;
    };
    RECYCLARR_CONF = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      format = "yaml";
      key = "";
      sopsFile = ./recyclarr.yaml;
    };
    RECYCLARR_SETTINGS = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      format = "yaml";
      key = "";
      sopsFile = ./recyclarr.settings.yaml;
    };
    QBITMANAGE_CONFIG_PUBLIC = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      format = "yaml";
      key = "";
      sopsFile = ./qbitmanage.public.yaml;
    };
    QBITMANAGE_CONFIG_PRIVATE = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      format = "yaml";
      key = "";
      sopsFile = ./qbitmanage.private.yaml;
    };
    CROSS_SEED_CONFIG_PUBLIC = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      format = "binary";
      sopsFile = ./cross-seed.public.config.js;
    };
    CROSS_SEED_CONFIG_PRIVATE = {
      owner = config.users.users.michael.name;
      group = config.users.groups.users.name;
      format = "binary";
      sopsFile = ./cross-seed.private.config.js;
    };
  };
}