{
  pkgs,
  inputs,
  config,
  osConfig,
  ...
}: {
  programs.vscode.profiles.default = {
    userSettings = {
      "nix.serverPath" = "nixd";
      "nix.enableLanguageServer" = true;
      "nix.serverSettings" = {
        # https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
        nixd = {
          nixpkgs = {
            # expr = "import <nixpkgs> {}";
            expr = "import (builtins.getFlake \"/etc/nixos\").inputs.nixpkgs { }";
          };
          formatting = {
            command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          };
          options = {
            nixos.expr = "(builtins.getFlake \"/etc/nixos/flake.nix\").nixosConfigurations.${osConfig.networking.hostName}.options";
            home-manager.expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.${config.home.username}.options.home-manager.users.type.getSubOptions []";
          };
        };
      };
    };
    extensions = with inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
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
