{
  config,
  pkgs,
  ...
}: let
  moreWaita = pkgs.morewaita-icon-theme.overrideAttrs (oldAttrs: rec {
    version = "80574a9c0e1242efd764368b1ec7dc77cd0ec67d";
    src = pkgs.fetchFromGitHub {
      owner = "somepaulo";
      repo = "MoreWaita";
      rev = "${version}";
      hash = "sha256-+xvRSsGc7ERFxiTj1HT7G29OCQkR0nUZ6+WN03D3AEQ=";
    };
  });
in {
  # imports = [
  #   ./steam.nix
  # ];

  fonts.fontconfig.enable = true;
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "graphite-light";
    size = 24;
    package = pkgs.graphite-cursors;
  };

  # https://github.com/Misterio77/nix-colors/blob/main/lib/contrib/gtk-theme.nix
  gtk = {
    # gtk3.extraConfig.gtk-decoration-layout = "menu:";
    # cursorTheme.name = "Qogir";
    enable = true;
    iconTheme.name = "Papirus";
    iconTheme.package = pkgs.papirus-icon-theme;
    # iconTheme.name = "MoreWaita";
    # iconTheme.package = moreWaita;

    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = 1;
    '';

    gtk3.extraCss = import ./adwaitaGtkCss.nix config.colorScheme;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraCss = import ./adwaitaGtkCss.nix config.colorScheme;
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    # theme.name = "Jasper-Grey-Dark-Compact";
  };

  qt = {
    enable = true;
    platformTheme = "gtk3";
    style.name = "adwaita-dark";
  };
}
