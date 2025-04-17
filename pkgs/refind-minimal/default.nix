{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "rEFInd-minimal";
  version = "2023-02-10"; # Use the date or actual version of the commit you want to pin

  # src = fetchFromGitHub {
  #   owner = "evanpurkhiser";
  #   repo = "rEFInd-minimal";
  #   rev = "cbebdb063072d4b1abfc0eef6bac26e9273abdf1"; # Preferably, use a specific commit for reproducibility
  #   sha256 = "sha256-YGyd5WEBm36dFtcOgVqPzQhXExHAPL9b038LoVa/Mp4="; # Replace with the actual SHA256 hash of the commit
  # };

  src = ./rEFInd-minimal; # Use a local copy of the theme for development

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

  meta = with lib; {
    description = "A minimal theme for rEFInd";
    homepage = "https://github.com/evanpurkhiser/rEFInd-minimal";
    license = licenses.mit;
    maintainers = with maintainers; []; # Add your maintainer name here if you wish
  };
}
