{ ... }:
{
  security = {
    rtkit.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  # View and manage keys and passwords
  programs.seahorse.enable = true;
}
