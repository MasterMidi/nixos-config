{modules, ...}: {
  imports = [
    modules.options.development
    ./android.nix
  ];

  development.rust = {
    enable = true;
    channel = "stable";
    rustRover = {
      enable = true;
      addHyprlandCompat = true;
    };
  };
}
