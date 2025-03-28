{config,...}: {
  virtualisation.oci-containers.compose.mediaserver.containers.newt = {
    image = "fosrl/newt";
    networking = {
      networks = ["default"];
      aliases = ["newt"];
    };
    environment = {
      PANGOLIN_ENDPOINT = "https://tunnel.mgrlab.dk";
      NEWT_ID = "a9sm7x55lx151eu";
    };
    secrets.env = {
      NEWT_SECRET.path = config.sops.secrets.PANGOLIN_NEWT_SECRET.path;
    };
  };
}
