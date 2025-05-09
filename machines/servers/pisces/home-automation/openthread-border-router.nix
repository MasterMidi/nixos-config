{
  pkgs,
  config,
  modules,
  ...
}: {
  imports = [modules.services.openthread-border-router modules.options.compose modules.services.podman-auto-update];

  # Setup the border router service
  services.openthread-border-router = rec {
    enable = true;
    package = pkgs.openthread-border-router;
    logLevel = "debug";
    backboneInterface = "enu1u1";
    radio = {
      # See https://www.phoscon.de/en/openthread/doc for setting details
      device = "/dev/serial/by-id/usb-dresden_elektronik_ConBee_III_DE03188707-if00-port0";
      baudRate = 115200;
      flowControl = false;
      # extraDevices = ["trel://${backboneInterface}"];
    };
  };

  # virtualisation.oci-containers.compose.home-assistant = {
  #   enable = false;
  #   networks.default = {};
  #   containers.otbr = {
  #     image = "openthread/border-router";
  #     networking = {
  #       useHostNetwork = true;
  #       # networks = ["host"];
  #     };
  #     environment = {
  #       OT_RCP_DEVICE = "spinel+hdlc+uart:///dev/ttyUSB0?uart-baudrate=115200";
  #       OT_INFRA_IF = "enu1u1";
  #       OT_THREAD_IF = "wpan0";
  #       OT_LOG_LEVEL = "7";
  #       REST_API = "1";
  #     };
  #     volumes = [
  #       "/var/lib/thread:/data"
  #     ];
  #     devices = [
  #       "/dev/net/tun"
  #       "/dev/ttyUSB0"
  #     ];
  #     capabilities = [
  #       "NET_ADMIN"
  #     ];
  #     extraOptions = ["--privileged"];
  #   };
  # };

  # Enable Avahi for mDNS discovery (important for Matter/Thread)
  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;
    nssmdns4 = true;
    nssmdns6 = true;
    publish = {
      enable = true;
      userServices = true;
    };
    # allowInterfaces = [config.services.openthread-border-router.backboneInterface];
  };

  # Add thread components to home-assistant
  services.home-assistant.extraComponents = [
    "otbr" # The border router component
    "thread" # The thread network component
  ];

  # Ensure necessary kernel modules for USB serial communication are loaded
  boot.kernelModules = ["ftdi_sio" "cdc_acm" "cp210x" "usbserial"];

  # Add the home-assistant user to necessary groups for hardware access
  # users.users.hass.extraGroups = ["dialout" "tty" "plugdev"];

  # Install additional tools that might be useful
  environment.systemPackages = with pkgs; [
    usbutils # lsusb and other USB utilities
  ];

  # Firewall configuration for openthread border router
  networking.firewall = {
    # enable = false;
    allowedTCPPorts = [
      config.services.openthread-border-router.web.listenPort
      config.services.openthread-border-router.rest.listenPort
    ];
    allowedUDPPorts = [
      9000 # Thread border router
    ];
  };
}
