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
  # ++ (
  #   builtins.map (mount: "d '${mount}' 0740 ${user} ${group} - -" config.systemd.services."podman-homarr".unitConfig.RequiresMountsFor)
  # );

  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/ajnart/homarr:latest";
    user = "${builtins.toString config.users.users.${user}.uid}:${builtins.toString config.users.groups.${group}.gid}";
    autoStart = true;
    ports = ["9000:7575"];
    volumes = [
      "${dataDir}/configs:/app/data/configs"
      "${dataDir}/data:/data"
      "${dataDir}/icons:/app/public/icons"
    ];
    log-driver = "journald";
  };
  systemd.services."podman-homarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = ["network-online.target"];
    requires = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig.RequiresMountsFor = [
      "${dataDir}/configs"
      "${dataDir}/data"
      "${dataDir}/icons"
    ];
  };
}
