{ ... }:
{
  flake.nixosModules.zed =
    { ... }:
    {
      programs.nix-ld.enable = true;
    };

  flake.homeModules.zed =
    { pkgs, ... }:
    {
      programs.zed-editor = {
        enable = true;
        mutableUserKeymaps = true;
        mutableUserSettings = true;
        mutableUserTasks = true;

        userSettings = {
          lsp.nixd = {
            nixpkgs.expr = "import (builtins.getFlake (builtins.toString ./.)).inputs.nixpkgs { }";
            formatting.command = "${pkgs.nixfmt}/bin/nixfmt";
          };
          languages.Nix.language_servers = [
            "nixd"
          ];
          format_on_save = "on";
          soft_wrap = "editor_width";
        };

        extensions = [
          "nix"
          "toml"
        ];
      };
    };
}
