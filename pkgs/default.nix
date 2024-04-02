# from "https://github.com/Misterio77/nix-starter-configs/blob/main/standard/pkgs/default.nix"
pkgs: {
  refindTheme.refind-minimal = pkgs.callPackage ./refind-minimal {};
  rofi-nerdy = pkgs.callPackage ./rofi-nerdy {};
  qbitmanage = pkgs.callPackage ./qbitmanage {};
  deej = pkgs.callPackage ./deej {};
}
