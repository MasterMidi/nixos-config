{...}: {
  services.qbitmanage = {
    enable = true;
    user = "michael";
    group = "users";
    config = builtins.readFile ./qbitmanage.config.yml;
    environment = {
      QBT_DRY_RUN = "false";
      QBT_SCHEDULE = "60";
    };
  };
}
