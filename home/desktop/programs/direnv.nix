{...}: {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    config = {
      warn_timeout = 0; # Disable timeout warning
      log_format = "-"; # Disable direnv logging
    };
  };
}
