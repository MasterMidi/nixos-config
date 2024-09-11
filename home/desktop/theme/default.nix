{
  config,
  pkgs,
  ...
}: {
  fonts.fontconfig.enable = true;
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "graphite-light";
    size = 24;
    package = pkgs.graphite-cursors;
  };

  # https://github.com/Misterio77/nix-colors/blob/main/lib/contrib/gtk-theme.nix
  # Setting GTK theme
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override {
        color = "paleorange";
      };
    };

    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = 1;
    '';

    gtk3 = {
      extraCss = import ./adwaitaGtkCss.nix config.colorScheme;
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    gtk4 = {
      extraCss = import ./adwaitaGtkCss.nix config.colorScheme;
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  dconf.settings = {
    # To set GTK4 to dark theme
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Setting QT theme
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  xdg.configFile = {
    "Kvantum/MateriaDark".source = "${pkgs.materia-kde-theme}/share/Kvantum/MateriaDark";
    "Kvantum/kvantum.kvconfig".text = "[General]\ntheme=MateriaDark";
  };

  home.packages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
  ];
}
