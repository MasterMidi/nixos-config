{ pkgs, ... }:
{
  # Booting theme
  boot.plymouth = {
    enable = true;
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/64x64/apps/nix-snowflake.png";
    theme = "angular_alt";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "angular_alt" ]; })
    ];
  };
}
