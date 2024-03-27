# https://codeberg.org/wolfangaukang/nix-agordoj/src/branch/main/home/users/bjorn/settings/firefox/default.nix
{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = with pkgs.nur.repos; [
      # wolfangaukang.vdhcoapp
    ];
  };
}
