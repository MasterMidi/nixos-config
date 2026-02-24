{ pkgs, self, ... }:
{
  imports = [
    self.modules.nixos.compose

    # ./autobrr.nix
    ./bazarr.nix
    # ./bitmagnet.nix
    # ./glance.nix
    # ./gotify.nix
    # ./homarr.nix
    ./immich.nix
    ./jdupes.nix
    # ./jellyfin
    # ./jellyseerr.nix
    # ./karakeep.nix
    ./mealie.nix
    ./newt.nix
    # ./open-webui.nix
    ./paperless.nix
    # ./penpot.nix
    # ./pocketid.nix
    ./prefetcher.nix
    # ./prowlarr.nix
    ./qbit
    # ./radarr.nix
    # ./recyclarr.nix
    # ./scrutiny.nix
    ./searxng.nix
    # ./sonarr.nix
    # ./sterling-pdf.nix
    # ./uptime-kuma.nix
  ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 8192; # fix a lot of filehandles from qbittorrent and other services simultaneously
    "fs.inotify.max_user_watches" = 524288;
  };

  environment.systemPackages = with pkgs; [
    mediainfo
    nvidia-container-toolkit
  ];

  systemd.services.k3s.path = with pkgs; [
    nvidia-container-toolkit # Provides nvidia-ctk
    # pkgs.nvidia-container-toolkit.tools # Provides nvidia-container-runtime
    libnvidia-container # Provides nvidia-container-cli
    runc
  ];

  environment.etc."nvidia-container-runtime/config.toml".text = ''
    disable-require = false

    [nvidia-container-cli]
    # Point directly to the libnvidia-container package
    path = "${pkgs.libnvidia-container}/bin/nvidia-container-cli"

    [nvidia-ctk]
    # Point directly to the default output of the toolkit
    path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk"
  '';

  services.k3s.containerdConfigTemplate = ''
    {{ template "base" . }}

    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
      privileged_without_host_devices = false
      runtime_engine = ""
      runtime_root = ""
      runtime_type = "io.containerd.runc.v2"
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
      BinaryName = "${pkgs.nvidia-container-toolkit.tools}/bin/nvidia-container-runtime"
      SystemdCgroup = true
  '';

  # virtualisation.oci-containers.compose.mediaserver.containers.subgen = {
  #   image = "docker.io/mccloud/subgen:cpu";
  #   autoUpdate = "registry";
  #   networking = {
  #     networks = [ "default" ];
  #     aliases = [ "subgen" ];
  #   };
  #   environment = {
  #     TRANSCRIBE_DEVICE = "cpu";
  #     WHISPER_MODEL = "large-v3";
  #   };
  #   volumes = [
  #     "/mnt/ssd/services/subgen/data/models:/subgen/models:rw"
  #   ];
  # };
}
