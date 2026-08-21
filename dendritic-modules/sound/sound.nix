{ ... }:
{
  flake.nixosModules.sound =
    { ... }:
    {
      services = {
        pulseaudio.enable = false;

        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;

          extraConfig.pipewire."92-low-latency" = {
            context.properties = {
              default.clock.rate = 48000;
              default.clock.quantum = 32;
              default.clock.min-quantum = 32;
              default.clock.max-quantum = 32;
            };
          };

          # Configure wireplumber
          wireplumber = {
            enable = true;
            extraConfig = {
              bluetoothEnhancements = {
                "monitor.bluez.properties" = {
                  "bluez5.enable-sbc-xq" = true;
                  "bluez5.enable-msbc" = true;
                  "bluez5.hfphsp-backend" = "native";
                  "bluez5.enable-hw-volume" = true;
                  "bluez5.codecs" = [
                    "sbc"
                    "sbc_xq"
                    "aac"
                  ];
                  "bluez5.roles" = [
                    "a2dp_sink"
                    "a2dp_source"
                    "bap_sink"
                    "bap_source"
                    "hsp_hs"
                    "hsp_ag"
                    "hfp_hf"
                    "hfp_ag"
                  ];
                };
              };
            };
          };
        };
      };
      # services.pulseaudio.extraConfig = "unload-module module-role-cork"; # Disable mute of audio streams when using phone stream (e.g. teamspeak)
    };
}
