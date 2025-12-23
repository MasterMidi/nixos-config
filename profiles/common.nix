{ pkgs, ... }:
{
  systemd.network.wait-online.anyInterface = true; # just need any connection, not all. Might help with the systemd unit failing

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    kitty.terminfo # for kitty terminal ssh support
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";
}
