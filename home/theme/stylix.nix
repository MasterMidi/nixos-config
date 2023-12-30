{pkgs, ...}: {
  stylix = {
    image = ../ahri.jpg;
    # polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    autoEnable = false;
    fonts = {
      monospace = {
        package = pkgs.meslo-lgs-nf;
        name = "MesloLGS Nerd Font";
      };
    };
    targets = {
      firefox.enable = true;
    };
  };
}
