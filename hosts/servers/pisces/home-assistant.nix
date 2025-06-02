# configuration.nix
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Enable the Home Assistant service
  services.home-assistant = {
    enable = true;
    openFirewall = true;

    # Basic configuration
    config = {
      # Core configuration
      homeassistant = {
        name = "Home";
        latitude = "40.7128"; # Replace with your latitude
        longitude = "-74.0060"; # Replace with your longitude
        elevation = 0;
        unit_system = "metric";
        currency = "DKK"; # Set to your currency
      };

      # Configure default config, history, logbook, etc.
      default_config = {};
      frontend = {};
      http = {
        # server_host = "::1";
        # trusted_proxies = ["::1"];
        # use_x_forwarded_for = true;
      };

      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";
    };

    # Automatically add the default Lovelace dashboard
    lovelaceConfigWritable = true; # makes it writeable, but overrides on restart
    lovelaceConfig = {
      title = "My Home";
      views = [
        {
          title = "Home";
          cards = [
            {
              type = "weather-forecast";
              entity = "weather.home";
            }
          ];
        }
      ];
    };

    # Configure the extraComponents or customComponents packages
    # to include the matter and thread support
    extraComponents = [
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"

      "radio_browser"
      "cast" # chromecast integration
      "met" # weather data
      "androidtv_remote"
      "jellyfin"
      "google_translate"

      # Include common protocols and devices
      "zha"
      "mqtt"
      "esphome"
      "bluetooth"
      "hassio" # Supervisor integration
      "matter"
      "thread"
      "otbr"
    ];

    # Add secrets that will be in your secrets.yaml
    extraPackages = python3Packages:
      with python3Packages; [
        # Add any Python dependencies needed by specific components
        pyserial
        pyserial-asyncio
        paho-mqtt
        aiohttp
      ];
  };

  services.matter-server = {
    enable = true;
    logLevel = "info";
    port = 5580;
  };

  services.openthread-border-router = {
    enable = true;
    package = pkgs.openthread-border-router;
    backboneInterface = "wlan0";
    radio = {
      device = "/dev/serial/by-id/usb-dresden_elektronik_ConBee_III_DE03188707-if00-port0";
      baudRate = 115200;
      flowControl = false;
    };
  };

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
    allowInterfaces = ["br0"]; # CHANGEME
  };

  # Firewall configuration for Home Assistant and related services
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # 80
      # 443 # Web access if needed
      1883
      8883 # MQTT
      5353 # mDNS
      5540 # Matter server
      8080 # OTBR web interface
    ];
    allowedUDPPorts = [
      5353 # mDNS
      5683
      5684 # CoAP/CoAPS for Matter
      9000 # Thread border router
    ];
  };

  # USB device configuration for ZigBee/Matter/Thread adapters
  services.udev.extraRules = ''
    # Silicon Labs USB stick persistence
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="ttyUSB_silabs", GROUP="dialout", MODE="0660"

    # For other Z-Wave/Zigbee adapters if you have them
    # SUBSYSTEM=="tty", ATTRS{idVendor}=="0658", ATTRS{idProduct}=="0200", SYMLINK+="ttyUSB_zwave", GROUP="dialout", MODE="0660"
  '';

  # Ensure necessary kernel modules for USB serial communication are loaded
  boot.kernelModules = ["ftdi_sio" "cdc_acm" "cp210x"];

  # Add the home-assistant user to necessary groups for hardware access
  users.users.home-assistant.extraGroups = ["dialout" "tty" "plugdev"];
  users.users.home-assistant.isSystemUser = true;
  users.users.home-assistant.group = "home-assistant";
  users.groups.home-assistant = {};

  # Install additional tools that might be useful
  environment.systemPackages = with pkgs; [
    usbutils # lsusb and other USB utilities
    socat # For socket debugging
    nmap # Network scanning tool
  ];

  # Create necessary directories with appropriate permissions
  # systemd.tmpfiles.rules = [
  #   "d /var/lib/matter-server 0755 home-assistant home-assistant -"
  #   "d /var/lib/otbr 0755 root root -"
  # ];
}
