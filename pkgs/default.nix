# from "https://github.com/Misterio77/nix-starter-configs/blob/main/standard/pkgs/default.nix"
final: {
  # refindTheme.refind-minimal = pkgs.callPackage ./refind-minimal {};
  refindTheme.refind-minimal = final.callPackage ./refind-minimal {};
}
