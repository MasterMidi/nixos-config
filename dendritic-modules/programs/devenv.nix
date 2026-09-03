{ ... }:
{
  flake.homeModules.devenv =
    {
      inputs,
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.devenv = {
        enable = true;
        enableBashIntegration = false;
        package = inputs.devenv-2_3.packages.${pkgs.stdenv.hostPlatform.system}.devenv;
      };
      programs = {
        bash.initExtra = lib.mkAfter ''
          eval "$(${lib.getExe config.programs.devenv.package} hook bash -- --no-tui)"
        '';
      };

      assertions = [
        {
          assertion = lib.versionOlder pkgs.devenv.version "2.3";
          message = ''
            devenv is now ${pkgs.devenv.version} in nixpkgs!.
            Remove the manual bash initExtra and use the update one directly from home-manager
          '';
        }
      ];
    };
}
