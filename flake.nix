{
  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    # flake-utils.follows = "nix-vscode-extensions/flake-utils";
    # nixpkgs.follows = "nix-vscode-extensions/nixpkgs";
  };

  outputs = { nixpkgs, nix-vscode-extensions, ... } @ inputs: {
    nixosConfigurations.jason = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; # this is the important part
      modules = [
        ./configuration.nix
      ];
    };
  };
}
