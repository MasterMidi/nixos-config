{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    # flake-utils.follows = "nix-vscode-extensions/flake-utils";
    # nixpkgs.follows = "nix-vscode-extensions/nixpkgs";
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , nur
    , home-manager
    , ...
    }:
    let
      inherit (self) outputs;

      username = "michael";
      userfullname = "Michael Andreas Graversen";
      useremail = "home@michael-graversen.dk";

    in
    {
      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs nixpkgs; };

      nixosConfigurations = {
        jason = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs outputs; }; # this is the important part
          modules = [
            ./hosts/jason
            { nixpkgs.overlays = [ nur.overlay ]; }

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.michael = import ./home;

              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
              home-manager.extraSpecialArgs = { inherit inputs outputs; };
            }
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    # homeConfigurations = {
    #   "michael@jason" = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
    #     # home-manager.useGlobalPkgs = true;
    #     # home-manager.useUserPackages = true;
    #     extraSpecialArgs = {inherit inputs outputs;};
    #     modules = [
    #       # > Our main home-manager configuration file <
    #       ./home
    #     ];
    #   };
    # };
    };
}
