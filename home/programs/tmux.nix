{ ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "kitty";
    mouse = true;
    keyMode = "vi";
    extraConfig = ''
      					set -g allow-passthrough on
      					set -ga update-environment TERM
      					set -ga update-environment TERM_PROGRAM
      				'';
  };
}
