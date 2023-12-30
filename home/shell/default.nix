{pkgs, ...}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellOptions = ["cdspell"];
    initExtra = ''
      . ~/.profile
      bind -s 'set completion-ignore-case on'
    '';
  };
}
