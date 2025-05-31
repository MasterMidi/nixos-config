{...}: {
  home.stateVersion = "23.11";

  services = {
    swayosd = {
      enable = true;
      display = "eDP-1";
    };
  };
}
