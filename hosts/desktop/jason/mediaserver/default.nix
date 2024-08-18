{
  pkgs,
  config,
  ...
}: let
  # mediaServerPath = builtins.toPath "${config.users.users.michael.home}/.temp/containers";
  mediaServerPath = builtins.toPath "/services/media";
in {
  imports = [
    ./qbitmanage.nix
    ./mediaserver.nix
  ];

  environment.systemPackages = with pkgs; [mediainfo];

  # virtualisation.containers.enable = true;
  # virtualisation.docker = {
  #   enable = true;
  #   rootless = {
  #     enable = true;
  #     setSocketVariable = true;
  #   };
  #   enableOnBoot = true;
  #   storageDriver = "btrfs";
  # };
  # virtualisation.podman = {
  #   enable = true;
  #   defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
  # };
  # virtualisation.oci-containers = {
  #   backend = "podman";
  #   containers = {
  #     homarr = {
  #       image = "ghcr.io/ajnart/homarr:latest";
  #       user = "1000:100";
  #       autoStart = true;
  #       ports = ["8000:7575"];
  #       volumes = [
  #         "${mediaServerPath}/homarr/configs:/app/data/configs"
  #         "${mediaServerPath}/homarr/data:/data"
  #         "${mediaServerPath}/homarr/icons:/app/public/icons"
  #         # "/var/run/docker.sock:/var/run/docker.sock"
  #       ];
  #       extraOptions = [
  #         "--network=mediaServer"
  #       ];
  #     };
  #     jellyfin = {
  #       image = "lscr.io/linuxserver/jellyfin:latest";
  #       autoStart = true;
  #       hostname = "jellyfin";
  #       ports = ["9010:8096" "8920:8920"];
  #       environment = {
  #         PUID = "1000";
  #         PGID = "100";
  #         TZ = "${config.time.timeZone}";
  #       };
  #       volumes = [
  #         "${mediaServerPath}/jellyfin/config:/config"
  #         "${mediaServerPath}/jellyfin/web:/jellyfin/jellyfin-web"
  #         "${mediaServerPath}/jellyfin/certs:/certs"
  #         "${mediaServerPath}/jellyfin/transcodes:/transcodes"
  #         "${config.users.users.michael.home}/.temp/data/media:/storage/media"
  #       ];
  #       extraOptions = [
  #         "--network=mediaServer"
  #       ];
  #     };
  #     jellyseerr = {
  #       image = "ghcr.io/hotio/jellyseerr";
  #       autoStart = true;
  #       ports = ["9020:5055"];
  #       environment = {
  #         PUID = "1000";
  #         PGID = "100";
  #         UMASK = "002";
  #         TZ = "${config.time.timeZone}";
  #       };
  #       volumes = [
  #         "${mediaServerPath}/jellyseerr/config:/config"
  #       ];
  #       extraOptions = [
  #         "--network=mediaServer"
  #       ];
  #     };
  #   };
  # };
  # systemd.services.create-mediaServer-network = with config.virtualisation.oci-containers; {
  #   serviceConfig.Type = "oneshot";
  #   wantedBy = [
  #     "${backend}-jellyseerr.service"
  #     "${backend}-jellyfin.service"
  #   ];
  #   script = ''
  #     ${pkgs.podman}/bin/podman network exists mediaServer || \
  #       ${pkgs.podman}/bin/podman network create mediaServer
  #   '';
  # };

  # systemd.services.create-mediaServer-pod = with config.virtualisation.oci-containers; {
  #   serviceConfig.Type = "oneshot";
  #   wantedBy = [
  #     "${backend}-jellyseerr.service"
  #     "${backend}-jellyfin.service"
  #   ];
  #   script = ''
  # 			${pkgs.podman}/bin/podman pod exists mediaServer || \
  # 				${pkgs.podman}/bin/podman pod create -n mediaServer \
  # 		-p '9010:8096' \
  # 		-p '8920:8920' \
  # 		-p '9020:5055' \
  #     -p '9030:7878' \
  #     -p '9040:8989' \
  #     -p '9050:9696' \
  #     -p '9060:9060'
  #   '';
  # };

  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = ["ve-+"];
  #   externalInterface = "ens3";
  #   # Lazy IPv6 connectivity for the container
  #   enableIPv6 = true;
  # };

  # containers.jellyseerr = {
  #   autoStart = true;
  #   privateNetwork = false;
  #   hostAddress = "192.168.50.10";
  #   localAddress = "192.168.50.11";
  #   config = {
  #     config,
  #     pkgs,
  #     lib,
  #     ...
  #   }: {
  #     services.jellyseerr = {
  #       enable = true;
  #       openFirewall = true;
  #       port = 8020;
  #     };

  #     system.stateVersion = "23.11";

  #     networking = {
  #       firewall = {
  #         enable = true;
  #         allowedTCPPorts = [8020];
  #       };
  #       # Use systemd-resolved inside the container
  #       # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
  #       useHostResolvConf = lib.mkForce false;
  #     };

  #     services.resolved.enable = true;
  #   };
  # };
}
