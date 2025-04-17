{
  rustPlatform,
  fetchFromGitHub,
  lib,
  # waylandSupport ? true,
  # x11Support ? true,
  # rofi,
  # wl-clipboard,
  # wtype,
  # xdotool,
  # xclip,
}:
rustPlatform.buildRustPackage rec {
  pname = "rofi-nerdy";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "Rolv-Apneseth";
    repo = "rofi-nerdy";
    rev = "v${version}";
    sha256 = "sha256-z3WGAJUpc3tNsG/QsOpuP+8hPLh7UaVQel53D4vA3lo=";
  };

  cargoPatches = [
    # a patch file to add/update Cargo.lock in the source code
    ./add-Cargo.lock.patch
  ];

  # cargoHash = "";

  meta = with lib; {
    description = "A simple emoji and character picker for rofi";
    homepage = "https://github.com/fdw/rofimoji";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [justinlovinger];
  };
}
