{pkgs, ...}: let
  # Create a package for the subtitle fonts
  subtitle-fonts = pkgs.stdenv.mkDerivation {
    name = "subtitle-fonts";
    version = "1.0";

    # This should be the directory containing all the font files you listed
    src = ./fonts;

    # No build needed, just installation
    buildPhase = "true";

    # Install all font files to appropriate directories
    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      mkdir -p $out/share/fonts/opentype

      # Copy TTF fonts
      find . -name "*.ttf" -o -name "*.TTF" -exec cp {} $out/share/fonts/truetype/ \;

      # Copy OTF fonts
      find . -name "*.otf" -o -name "*.OTF" -exec cp {} $out/share/fonts/opentype/ \;
    '';
  };
in {
  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;

    packages = with pkgs; [
      subtitle-fonts

      # Standard Microsoft fonts (includes Verdana, TEMPSITC, etc.)
      # corefonts

      # Comfortaa is available in Google Fonts package
      google-fonts

      # Noto fonts for general coverage
      noto-fonts

      # Liberation fonts for general coverage
      liberation_ttf
    ];
  };
}
