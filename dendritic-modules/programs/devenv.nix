{ ... }:
{
  flake.homeModules.devenv =
    {
      lib,
      config,
      ...
    }:
    {
      programs.devenv = {
        enable = true;
        enableBashIntegration = false;
      };
      programs = {
        bash.initExtra = lib.mkAfter ''
          eval "$(${lib.getExe config.programs.devenv.package} hook bash -- --no-tui)"
        '';
      };
    };
}
