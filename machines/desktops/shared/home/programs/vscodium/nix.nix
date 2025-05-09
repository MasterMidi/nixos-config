{
  pkgs,
  inputs,
  config,
  ...
}: {
  programs.vscode = {
    userSettings = {
      "nix.serverPath" = "nixd";
      "nix.enableLanguageServer" = true;
      "nix.serverSettings" = {
        nixd = {
          nixpkgs = {
            expr = "import <nixpkgs> {}";
          };
          formatting = {
            command = "${pkgs.alejandra}/bin/alejandra";
          };
          options = {
            nixos = {
              expr = "(builtins.getFlake \"/etc/nixos/flake.nix\").nixosConfigurations.jason.options";
            };
          };
        };
      };
    };
    extensions = with inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
      kamadorueda.alejandra
      jeff-hykin.better-nix-syntax
      arrterian.nix-env-selector
      jnoortheen.nix-ide
    ];
  };

  # Language tools
  home.packages = with pkgs; [
    # Nix tools
    nil
    nixd
    nixpkgs-fmt
    alejandra
  ];
}
