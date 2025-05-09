{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kitty.terminfo # for kitty terminal ssh support
    whereami # easily find nix store path for executable
  ];
}
