{config, ...}: {
  imports = [
    ./matter.nix
    ./openthread-border-router.nix
  ];

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

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 640 hass hass -"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 640 hass hass -"
    "f ${config.services.home-assistant.configDir}/scripts.yaml 640 hass hass -"
  ];
}
