{...}: {
  services.qbitmanage = {
    enable = true;
    user = "michael";
    group = "users";
    config = ./qbitmanage.config.yml;
    environment = {
      QBT_DRY_RUN = "false";
      QBT_SCHEDULE = "60";
    };
    volumes = [
      "/home/michael/.temp/data/torrents:/storage/torrents"
      "/mnt/storage/media/torrents:/cold/torrents"
    ];
  };
}
