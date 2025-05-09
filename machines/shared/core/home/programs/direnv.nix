{config, ...}: {
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = config.programs.bash.enable;
      nix-direnv.enable = true;
    };
  };

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = ""; # Disable direnv logging
  };
}
