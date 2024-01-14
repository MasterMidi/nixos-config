{
  configs,
  pkgs,
  ...
}: {
  # imports = [
  #   ./steam.nix
  # ];

  fonts.fontconfig.enable = true;
  home.pointerCursor = let
    getFrom = url: hash: name: {
      gtk.enable = true;
      x11.enable = false;
      name = name;
      size = 24;
      package = pkgs.runCommand "moveUp" {} ''
        mkdir -p $out/share/icons
        ln -s ${pkgs.fetchzip {
          url = url;
          hash = hash;
        }}/dist-light $out/share/icons/${name}
      '';
    };
  in
    getFrom
    "https://github.com/vinceliuice/Graphite-cursors/archive/refs/heads/main.zip"
    "sha256-abnCIoPTbhyeWVBLiNjBI2+/6IIQ6I6lS/rvoVrselY="
    "Graphite-cursors-light";

  gtk = {
    # gtk3.extraConfig.gtk-decoration-layout = "menu:";
    # cursorTheme.name = "Qogir";
    enable = true;
    # theme.name = "Colloid";
    # theme.package = pkgs.colloid-gtk-theme;
    iconTheme.name = "Adwaita";
    iconTheme.package = pkgs.gnome3.adwaita-icon-theme;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    # theme.name = "Jasper-Grey-Dark-Compact";
  };
}
