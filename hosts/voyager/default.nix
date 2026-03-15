{
  inputs,
  self,
  ...
}:
{
  flake = {
    nixosConfigurations.voyager = inputs.nixos-raspberrypi.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        inherit (inputs) nixos-raspberrypi;
      };
      modules = [
        ./configuration.nix
        ./system.nix
        # ./home-assistant.nix

        self.modules.nixos.openthread-border-router
        inputs.nixos-raspberrypi.nixosModules.sd-image

        # ./home-assistant.nix
        {
          # Hardware specific configuration, see section below for a more complete
          # list of modules
          imports = with inputs.nixos-raspberrypi.nixosModules; [
            raspberry-pi-3.base
          ];

          sdImage.compressImage = true;

          nixpkgs.overlays = [ self.overlays.default ];
        }

        {
          networking.firewall.allowedTCPPorts = [
            8081
            8080
            8082
          ];

          services.openthread-border-router = {
            enable = true;
            backboneInterface = "enu1u1";
            rest = {
              listenAddress = "::";
            };
            web = {
              enable = true;
              listenAddress = "::";
            };
            radio = {
              device = "/dev/serial/by-id/usb-dresden_elektronik_ConBee_III_DE03188707-if00-port0";
              baudRate = 115200;
              flowControl = false;
            };
          };

          # LOAD THESE MODULES for OTBR / Container NAT
          boot.kernelModules = [
            "br_netfilter"
            "iptable_nat"
            "iptable_filter"
            "iptable_mangle"
            "xt_NAT"
            "ipt_MASQUERADE"
            "ip6_tables"
            "ip6table_filter"
            "ip6table_nat" # Critical for Thread IPv6 NAT
            "ip6table_mangle"
            "tun"
          ];

          # Ensure the firewall doesn't block the container's internal bridges
          networking.firewall.checkReversePath = "loose";

          networking.nat.enable = true;
          networking.nat.externalInterface = "enu1u1";

          # 3. Enable legacy iptables compatibility (OTBR relies on this)
          networking.nftables.enable = false; # Ensure we aren't "nftables only"
          networking.firewall.enable = true;

          # boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

          # This forces NixOS to include all legacy iptables/NAT modules in the build.
          virtualisation.docker.enable = true;
        }

        # profiles
        ../../profiles/common.nix
        ../../profiles/nix.nix
        # ../../profiles/secrets.nix
        ../../profiles/vpn.nix
        # ../../profiles/k3s.nix

        # Users
        ../../users/root/common.nix
        ../../users/michael/server
      ];
    };
  };

  deploy.nodes.voyager = {
    hostname = "voyager";
    profiles.system = {
      sshUser = "root";
      path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.voyager;
      remoteBuild = false;
      magicRollback = false;
      autoRollback = false;
    };
  };
}
