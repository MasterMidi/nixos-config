{modules, ...}: {
  imports = [
    modules.options.development
  ];

  development = {
    android = {
      enable = true;
      flutter.enable = true;
    };
    dotnet = {
      enable = true;
      rider = {
        enable = true;
        addHyprlandCompat = true;
      };
      sdkVersion = "sdk_9_0";
    };
    rust = {
      enable = true;
      channel = "stable";
      rustRover = {
        enable = true;
        addHyprlandCompat = true;
      };
    };
  };
}
