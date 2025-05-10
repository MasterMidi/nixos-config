{config, ...}: {
  programs.eza = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    git = config.programs.git.enable;
    icons = "auto";
  };
}
