{inputs, ...}: {
  nix.buildMachines = with inputs.self.nixosConfigurations; [
    {
      hostName = jason.config.networking.hostName;
      supportedFeatures = jason.config.nix.settings.system-features;
      systems = [jason.config.nixpkgs.buildPlatform "aarch64-linux"];
      protocol = "ssh-ng";
      maxJobs = 1;
      speedFactor = 5;
    }
    {
      hostName = andromeda.config.networking.hostName;
      supportedFeatures = andromeda.config.nix.settings.system-features;
      systems = [andromeda.config.nixpkgs.buildPlatform "aarch64-linux"];
      protocol = "ssh-ng";
      maxJobs = 1;
      speedFactor = 3;
    }
  ];

  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
}
