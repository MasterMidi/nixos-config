{inputs, ...}: {
  imports = [
    ./programs/starship.nix
    ./shell
    ./nix.nix
  ];

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
}
