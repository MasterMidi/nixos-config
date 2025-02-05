{
  pkgs,
  config,
  ...
}: {
  boot.kernelModules = ["cdc_acm" "usbserial" "ftdi_sio"];
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w" # required for matter integration
  ];
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "met"
      "radio_browser"

      # Components that are not part of the default setup
      # "otbr" # OpenThread Border Router
      # "matter" # Matter integration
      "thread" # Thread integration
      "jellyfin" # Jellyfin integration
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
      automation = [
        {
          alias = "Turn plantlights ON";
          description = "Turns all plants lights on";
          trigger = {
            platform = "time";
            at = "7:00:00";
          };
          action = [
            {
              type = "turn_on";
              device_id = "8bd0c77ebbf00a9e84c8407d9cea9b7a";
              entity_id = "2d03e0bf0825f73c4c56a48bb5c3cf56";
              domain = "switch";
            }
            {
              type = "turn_on";
              device_id = "e9c5895590ed6d3bbfc74417b7968d8c";
              entity_id = "562bc572390367ea27cc9a4ddc9cc214";
              domain = "switch";
            }
          ];
        }
        {
          alias = "Turn plantlights OFF";
          description = "Turns all plants lights off";
          trigger = {
            platform = "time";
            at = "20:00:00";
          };
          action = [
            {
              type = "turn_off";
              device_id = "8bd0c77ebbf00a9e84c8407d9cea9b7a";
              entity_id = "2d03e0bf0825f73c4c56a48bb5c3cf56";
              domain = "switch";
            }
            {
              type = "turn_off";
              device_id = "e9c5895590ed6d3bbfc74417b7968d8c";
              entity_id = "562bc572390367ea27cc9a4ddc9cc214";
              domain = "switch";
            }
          ];
        }
      ];
      # matter = {
      #   log_level = "info";
      #   log_level_sdk = "error";
      #   beta = false;
      #   enable_test_net_dcl = false;
      # };
      otbr = {
        device = "";
        baudrate = 115200;
        flow_control = false;
        autoflash_firmware = false;
        otbr_log_level = "notice";
        firewall = true;
        nat64 = true;
      };
    };
  };

  virtualisation.oci-containers.compose.home-assistant = {
    enable = true;
    networks.default = {};
    containers = {
      openthread-border-router = {
        image = "siliconlabsinc/openthread-border-router:gsdk-4.2.0";
        networking = {
          networks = ["default"];
          aliases = ["otbr"];
          ports = {
            ui = {
              host = 8888;
              internal = 80;
            };
          };
        };
        devices = [
          "/dev/serial/by-id/usb-dresden_elektronik_ConBee_III_DE03188707-if00-port0"
        ];
        commands = ["radio-url spinel+hdlc+uart:///dev/serial/by-id/usb-dresden_elektronik_ConBee_III_DE03188707-if00-port0?uart-baudrate=115200 --backbone-interface eth0"];
        extraOptions = [
          "--sysctl=net.ipv6.conf.all.forwarding=1"
          "--sysctl=net.ipv6.conf.all.disable_ipv6=0"
          "--sysctl=net.ipv4.conf.all.forwarding=1"
          "--dns=127.0.0.1"
        ];
      };
    };
  };

  # Runtime
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
      # network_interface = "podman0";
    };
  };
  virtualisation.oci-containers.backend = "podman";

  # Firewall
  networking.firewall.interfaces."podman+".allowedUDPPorts = [53 5353];
}
