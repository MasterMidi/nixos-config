{
  lib,
  config,
  ...
}: let
  dataDir = "/var/lib/homarr";
  user = "homarr";
  group = "media";
in {
  networking.firewall.allowedTCPPorts = [7575 9000];

  users.users = {
    "${user}" = {
      inherit group;
      isSystemUser = true;
      home = dataDir;
      uid = 7575;
      description = "qBittorrent service user";
    };
  };

  # users.groups = {
  #   "${group}".gid = 7575;
  # };

  systemd.tmpfiles.rules = [
    "d '${dataDir}' 0740 ${user} ${group} - -"
    "d '${dataDir}/configs' 0740 ${user} ${group} - -"
    "d '${dataDir}/data' 0740 ${user} ${group} - -"
    "d '${dataDir}/icons' 0740 ${user} ${group} - -"
  ];

  virtualisation.oci-containers = {
    containers = {
      homarr = {
        image = "ghcr.io/ajnart/homarr:latest";
        user = "${builtins.toString config.users.users."${user}".uid}:${builtins.toString config.users.groups."${group}".gid}";
        autoStart = true;
        ports = ["9000:7575"];
        volumes = [
          "${dataDir}/configs:/app/data/configs"
          "${dataDir}/data:/data"
          "${dataDir}/icons:/app/public/icons"
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        extraOptions = [
          # "--network=host"
        ];
      };
    };
  };
}
