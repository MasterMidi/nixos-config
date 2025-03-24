{pkgs, ...}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellOptions = [
      "cdspell"
      "dirspell"
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "checkjobs"
    ];
    initExtra = ''
      . ~/.profile
      bind -s 'set completion-ignore-case on'
    '';
    bashrcExtra = ''
      ${builtins.readFile ./nix-direnv.sh}
    '';
  };
}
