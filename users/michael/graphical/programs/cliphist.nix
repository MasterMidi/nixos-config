{
  lib,
  pkgs,
  ...
}:
{
  services.cliphist.enable = true; # clipboard support

  # Runs once at Hyprland startup (replaces hyprlang's exec-once)
  wayland.windowManager.hyprland.settings.on = [
    {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline "function() hl.exec_cmd(\"${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store\") end")
      ];
    } # start clipboard manager
  ];
}
