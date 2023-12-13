{pkgs,...}:

{
  programs.bash = {
    enable = true;
    initExtra = ''
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      bind -s 'set completion-ignore-case on'
    '';

    shellOptions = [ "cdspell" ];
  };
}