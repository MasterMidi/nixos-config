{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kitty.terminfo # for kitty terminal ssh support
    btop # system monitor utility
  ];
}
