{ ... }:
{
  flake.homeModules.kubectl =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.kubectl;
      yamlFormat = pkgs.formats.yaml { };
      kubeconfigFile = yamlFormat.generate "kubectl-config" cfg.settings;
    in
    {
      options.programs.kubectl = {
        enable = lib.mkEnableOption "kubectl";
        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "kubectl configuration written to a file in the Nix store and referenced via KUBECONFIG.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.kubectl ];

        home.sessionVariables.KUBECONFIG = "${kubeconfigFile}";
      };
    };
}
