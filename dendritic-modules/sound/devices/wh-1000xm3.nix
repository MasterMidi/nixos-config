# Config for my sony wireless headphones
{ ... }:
{
  flake.nixosModules.sound-wh-1000xm3 =
    { ... }:
    {
      services.pipewire.wireplumber.extraConfig = {
        "wh-1000xm3-ldac-hq" = {
          "monitor.bluez.rules" = [
            {
              matches = [
                {
                  # Match any bluetooth device with ids equal to that of a WH-1000XM3
                  "device.name" = "~bluez_card.*";
                  "device.product.id" = "0x0cd3";
                  "device.vendor.id" = "usb:054c";
                }
              ];
              actions = {
                update-props = {
                  # Set quality to high quality instead of the default of auto
                  "bluez5.a2dp.ldac.quality" = "hq";
                };
              };
            }
          ];
        };
      };
    };
}
