{
  config,
  pkgs,
  ...
}: {
  services.matter-server = {
    port = 5580;
    enable = true;
    logLevel = "debug";
    extraArgs = let
      cert-dir = pkgs.fetchFromGitHub {
        repo = "connectedhomeip";
        owner = "project-chip";
        rev = "6e8676be6142bb541fa68048c77f2fc56a21c7b1";
        hash = "sha256-QwPKn2R4mflTKMyr1k4xF04t0PJIlzNCOdXEiQwX5wk=";
      };
    in [
      "--bluetooth-adapter=0"
      "--paa-root-cert-dir=${cert-dir}/credentials/production/paa-root-certs"
      "--enable-test-net-dcl"
      "--ota-provider-dir=/var/lib/matter-server/ota-provider"
    ];
  };

  # Add matter components to home-assistant
  services.home-assistant = {
    extraComponents = [
      "matter"
    ];
    extraPackages = python3Packages:
      with python3Packages; [
        numpy
        python-matter-server
        universal-silabs-flasher
      ];
  };

  # Firewall configuration for matter service
  networking.firewall = {
    allowedTCPPorts = [
      config.services.matter-server.port # Matter server
    ];
    allowedUDPPorts = [
      # CoAP/CoAPS for Matter
      5683
      5684
    ];
  };
}
