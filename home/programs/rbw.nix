{pkgs, ...}
: {
  programs.rbw = {
    enable = true;
    settings = {
      email = "home@michael-graversen.dk";
      pinentry = pkgs.pinentry-gnome3; # TODO: switch to pinentry-rofi when i can get it working????
    };
  };
}
# https://vault.bitwarden.com/#/settings/security/security-keys

