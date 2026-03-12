{ ... }:
{
  flake.nixosModules.client =
    { ... }:
    {
      nix = {
        # 1. Globally enable distributed builds
        distributedBuilds = true;

        # 2. Define the remote builders
        buildMachines = [
          {
            hostName = "zenith"; # Replace with your builder's IP or hostname
            system = "x86_64-linux"; # The native architecture of the builder

            # The `systems` attribute tells Nix what this machine is CAPABLE of building.
            # Because we added QEMU to the builder, we list aarch64-linux here too.
            systems = [
              "x86_64-linux"
              "aarch64-linux"
            ];

            # ssh-ng is a specialized, faster Nix protocol over SSH
            protocol = "ssh-ng";

            # The maximum number of concurrent jobs the builder can handle
            maxJobs = 8;

            # A relative speed rating. A Pi might be '1', your server might be '3'.
            speedFactor = 3;

            # Supported features dictate what special derivations this builder can handle
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];

            sshUser = "nix-builder";

            # IMPORTANT: This is the path to the private key on the CLIENT.
            # Because the nix-daemon runs as root, this path is relative to the root user.
            sshKey = "/root/.ssh/nix-builder-key";
          }
        ];
      };

      # 3. Prevent interactive SSH prompts from hanging the Nix daemon
      # You must provide the SSH Host public key of your builder machine here.
      # You can fetch it by running: ssh-keyscan builder.homelab.local
      programs.ssh.knownHosts."builder.homelab.local" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/wwcgUh2vV59HySfZKgRDxI69eHHIrOAEVyWZNxvfY nix-remote-builder";
      };
    };
}
