{
  pkgs,
  inputs,
  config,
  osConfig,
  ...
}:
let
  vscodeExtension =
    inputs.nix-vscode-extensions.extensions.${osConfig.nixpkgs.hostPlatform.system}.vscode-marketplace;
in
{
  programs.vscode.profiles.default = {
    userSettings = {
      nix = {
        serverPath = "nixd";
        enableLanguageServer = true;
        serverSettings = {
          # https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
          nixd = {
            nixpkgs.expr = "import (builtins.getFlake \"/etc/nixos\").inputs.nixpkgs { }";
            formatting.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
            options = {
              nixos.expr = "(builtins.getFlake \"/etc/nixos/flake.nix\").nixosConfigurations.${osConfig.networking.hostName}.options";
              home-manager.expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.${config.home.username}.options.home-manager.users.type.getSubOptions []";
            };
          };
        };
      };
      "[nix]" = {
        editor.defaultFormatter = "jnoortheen.nix-ide";
      };
    };
    extensions = with vscodeExtension; [
      jeff-hykin.better-nix-syntax
      arrterian.nix-env-selector
      jnoortheen.nix-ide
    ];
  };

  # Language tools
  home.packages = with pkgs; [
    # Nix tools
    nixd
    nixfmt-rfc-style
  ];
}
