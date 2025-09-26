{ config, ... }:
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    nix-direnv.enable = true;
    silent = true;
    config = {
      warn_timeout = 0; # Disable timeout warning
    };
  };
}
