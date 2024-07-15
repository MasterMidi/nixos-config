{pkgs, ...}: {
  # Enable sound with pipewire.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
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

      # https://github.com/NixOS/nixpkgs/pull/292115
      # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
          bluez_monitor.properties = {
          	["bluez5.enable-sbc-xq"] = true,
          	["bluez5.enable-msbc"] = true,
          	["bluez5.enable-hw-volume"] = true,
          	["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
          }
        '')
      ];
    };
  };
  # hardware.pulseaudio.extraConfig = "unload-module module-role-cork"; # Disable mute of audio streams when using phone stream (e.g. teamspeak)

  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot

    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;
}
