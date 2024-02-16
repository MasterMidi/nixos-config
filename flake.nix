{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs-legacy.url = "github:nixos/nixpkgs/nixos-23.05";
    nur.url = "github:nix-community/NUR";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lollypops.url = "github:pinpox/lollypops";
    agenix.url = "github:ryantm/agenix";

    hyprland.url = "github:hyprwm/Hyprland";
    nix-gaming.url = "github:fufexan/nix-gaming";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    themes.url = "github:RGBCube/ThemeNix";
    # stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    nur,
    home-manager,
    nixos-hardware,
    lollypops,
    agenix,
    themes,
    ...
  } @ inputs: let
    inherit (self) outputs;

    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    username = "michael";
    userfullname = "Michael Andreas Graversen";
    useremail = "home@michael-graversen.dk";
  in rec {
    # Custom packages and modifications, exported as overlays
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules;

    nixosConfigurations = {
      jason = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {inherit inputs outputs;}; # this is the important part
        modules = [
          ./hosts/jason
          ./scripts
          inputs.nix-gaming.nixosModules.pipewireLowLatency
          inputs.nix-gaming.nixosModules.steamCompat
          outputs.nixosModules.refind
          agenix.nixosModules.default
          lollypops.nixosModules.lollypops

          nixos-hardware.nixosModules.lenovo-ideapad-slim-5
          nixos-hardware.nixosModules.common-cpu-amd-pstate

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.michael = import ./home;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            home-manager.extraSpecialArgs = let
              theme = themes.gruvbox-dark-medium;
            in {inherit inputs outputs theme;};
          }
          {
            nixpkgs.overlays = [
              nur.overlay
              overlays.vscode-extensions
              overlays.additions
            ];
          }
        ];
      };

      # daniel = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";

      #   specialArgs = {inherit inputs outputs;}; # this is the important part
      #   modules = [
      #     ./hosts/daniel
      #     ./scripts
      #     lollypops.nixosModules.lollypops

      #     home-manager.nixosModules.home-manager
      #     {
      #       home-manager.useGlobalPkgs = true;
      #       home-manager.useUserPackages = true;

      #       home-manager.users.michael = import ./home;

      #       # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
      #       home-manager.extraSpecialArgs = {inherit inputs outputs;};
      #     }
      #   ];
      # };

      nixpi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        specialArgs = {inherit inputs outputs;}; # this is the important part
        modules = [
          ./hosts/nixpi
          agenix.nixosModules.default
          lollypops.nixosModules.lollypops
        ];
      };

      envpi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        specialArgs = {inherit inputs outputs;}; # this is the important part
        modules = [
          ./hosts/envpi
          agenix.nixosModules.default
          lollypops.nixosModules.lollypops
        ];
      };

      david = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {inherit inputs outputs;}; # this is the important part
        modules = [
          ./hosts/david
          outputs.nixosModules.bitmagnet
          agenix.nixosModules.default
          lollypops.nixosModules.lollypops
        ];
      };
    };

    apps."x86_64-linux".default = lollypops.apps."x86_64-linux".default {configFlake = self;};
  };
}
