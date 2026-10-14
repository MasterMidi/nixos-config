{ self, ... }:
{
  flake.homeModules.wluma =
    { inputs, config, ... }:
    {
      services.wluma = {
        enable = true;
        settings = { };
        systemd = {
          enable = true;
          target = "hyprland-session.target";
        };
      };
    };
}
