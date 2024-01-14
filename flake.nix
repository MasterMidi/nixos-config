{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-legacy.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    nix-gaming.url = "github:fufexan/nix-gaming";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    stylix.url = "github:danth/stylix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nur,
    home-manager,
    ...
  }: let
    inherit (self) outputs;

    username = "michael";
    userfullname = "Michael Andreas Graversen";
    useremail = "home@michael-graversen.dk";
  in {
    # Custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    nixosConfigurations = {
      jason = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {inherit inputs outputs;}; # this is the important part
        modules = [
          ./hosts/jason
          ./scripts
          inputs.nixpkgs-chaotic.nixosModules.default
          inputs.nix-gaming.nixosModules.pipewireLowLatency
          inputs.nix-gaming.nixosModules.steamCompat
          # inputs.stylix.nixosModules.stylix
          # { nixpkgs.overlays = [ nur.overlay ]; }

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.michael = import ./home;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
          }
        ];
      };

      daniel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {inherit inputs outputs;}; # this is the important part
        modules = [
          ./hosts/daniel
          ./scripts

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.michael = import ./home;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
          }
        ];
      };

      nixpi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        specialArgs = {inherit inputs outputs;}; # this is the important part
        modules = [
          ./hosts/nixpi
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
