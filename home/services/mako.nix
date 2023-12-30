{ ... }:
{
  services.mako = {
    enable = true;
    defaultTimeout = 3000;
    ignoreTimeout = false; # set to true to only use defaut timeout
    sort = "-time";
    layer = "overlay";
    backgroundColor = "#2b3339CC";
    width = 300;
    height = 100;
    borderSize = 2;
    borderColor = "#4c566a";
    borderRadius = 17;
    icons = true;
    maxIconSize = 64;
    font = "MesloLGS Nerd Font 10";
    anchor = "top-right";
    markup = true;

    # TODO add urgencies like mako.urgency.low.borderColor = "#...";
    # TODO make custom override to set this in a nix fasion
    # like mako.category.<name>.defaultTimeout = 20000;
    extraConfig = ''
      [urgency=low]
      border-color=#cccccc

      [urgency=normal]
      border-color=#d08770

      [urgency=high]
      border-color=#bf616a
      default-timeout=0

      [category=mpd]
      default-timeout=20000
      group-by=category
    '';
  };
}
