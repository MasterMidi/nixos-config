{pkgs,...}:

{
  programs.bash = {
    enable = true;
    initExtra = ''
      bind -s 'set completion-ignore-case on'
    '';

    shellOptions = [ "cdspell" ];
  };
}