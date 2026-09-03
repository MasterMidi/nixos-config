{ inputs, self, ... }:
{
  flake = {
    nixosConfigurations.zenith = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        self.nixosModules.nix-builder
        # self.nixosModules.k3s-node-agent
        self.nixosModules.hyprland
        self.nixosModules.tailscale
        self.nixosModules.zed

        ./services
        ./configuration.nix
        ./development.nix
        ./gaming.nix
        ./graphical.nix
        ./hardware.nix
        self.nixosModules.facter
        ./security.nix
        ./sound.nix
        ./system.nix
        ./virtualization.nix

        # profiles
        ../../profiles/common.nix
        self.nixosModules.fw-updates
        self.nixosModules.avahi
        ../../profiles/monitor-control.nix
        self.nixosModules.nix-interactive-machine
        self.nixosModules.sops
        self.nixosModules.bluetooth
        self.nixosModules.sound
        self.nixosModules.sound-wh-1000xm3
        self.nixosModules.boot-splash-screen

        # Users
        ../../users/root/common.nix
        ../../users/michael/zenith
        {
          home-manager.users.michael.imports = [
            self.homeModules.k8s-cluster-administration
            self.homeModules.hyprland
            self.homeModules.jujutsu
            self.homeModules.opencode
            self.homeModules.zed
            self.homeModules.devenv
          ];
        }
      ];
    };
    diskoConfigurations.zenith = import ./disko.nix;
  };

  deploy.nodes.zenith = {
    hostname = "zenith";
    profiles.system = {
      sshUser = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.zenith;
      remoteBuild = true;
    };
  };

  builder.zenith = {
    hostName = "zenith";
    system = "x86_64-linux";
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maxJobs = 8;
    speedFactor = 3;
    supportedFeatures = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
    ];
    # IMPORTANT: The SSH host key of the builder machine itself
    hostPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...<zenith-host-key-here>";
  };
}
