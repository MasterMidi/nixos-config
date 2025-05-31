{...}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellOptions = [
      "cdspell"
      "dirspell"
			"direxpand"
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
  };
}
