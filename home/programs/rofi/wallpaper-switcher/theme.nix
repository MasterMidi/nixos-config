{config, ...}: let
  inherit (config.lib.formats.rasi) mkLiteral;

  border-colour = mkLiteral "var(selected)";
  handle-colour = mkLiteral "var(selected)";
  background-colour = mkLiteral "var(background)";
  foreground-colour = mkLiteral "var(foreground)";
  alternate-background = mkLiteral "var(background-alt)";
  normal-background = mkLiteral "var(background)";
  normal-foreground = mkLiteral "var(foreground)";
  urgent-background = mkLiteral "var(urgent)";
  urgent-foreground = mkLiteral "var(background)";
  active-background = mkLiteral "var(active)";
  active-foreground = mkLiteral "var(background)";
  selected-normal-background = mkLiteral "var(selected)";
  selected-normal-foreground = mkLiteral "var(background)";
  selected-urgent-background = mkLiteral "var(active)";
  selected-urgent-foreground = mkLiteral "var(background)";
  selected-active-background = mkLiteral "var(urgent)";
  selected-active-foreground = mkLiteral "var(background)";
  alternate-normal-background = mkLiteral "var(background)";
  alternate-normal-foreground = mkLiteral "var(foreground)";
  alternate-urgent-background = mkLiteral "var(urgent)";
  alternate-urgent-foreground = mkLiteral "var(background)";
  alternate-active-background = mkLiteral "var(active)";
  alternate-active-foreground = mkLiteral "var(background)";
in {
  "@import" = "colors.rasi";

  # Main Window

  window = {
    enabled = true;
    fullscreen = false;
    width = mkLiteral "100%";
    transparency = "real";
    cursor = "default";
    spacing = mkLiteral "0px";
    padding = mkLiteral "0px";
    border = mkLiteral "0px";
    border-radius = mkLiteral "0px";
    border-color = mkLiteral "transparent";
    background-color = mkLiteral "transparent";
  };

  # Main Box

  mainbox = {
    enabled = true;
    children = map mkLiteral ["inputbar" "listview"];
    background-color = background-colour;
  };

  # Input

  inputbar = {
    horizontal-align = mkLiteral "0.5";
    enabled = true;
    spacing = mkLiteral "10px";
    margin = mkLiteral "20px 30% 0% 30%";
    padding = mkLiteral "8px 12px";
    border = mkLiteral "0px solid";
    border-radius = mkLiteral "8px";
    border-color = border-colour;
    background-color = alternate-background;
    text-color = foreground-colour;
    children = map mkLiteral ["textbox-prompt-colon" "entry"];
  };

  prompt = {
    horizontal-align = mkLiteral "inherit";
    enabled = true;
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  textbox-prompt-colon = {
    horizontal-align = mkLiteral "inherit";
    enabled = true;
    padding = mkLiteral "5px 0px";
    expand = false;
    str = " ";
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  entry = {
    horizontal-align = mkLiteral "inherit";
    enabled = true;
    padding = mkLiteral "5px 0px";
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
    cursor = mkLiteral "text";
    placeholder = "Search...";
    placeholder-color = mkLiteral "inherit";
  };

  # Listview

  listview = {
    enabled = true;
    columns = 7;
    lines = 1;
    spacing = mkLiteral "50px";
    padding = mkLiteral "20px 30px";
    cycle = true;
    dynamic = true;
    scrollbar = false;
    /*
    TODO= make it vertical scroll
    */
    layout = mkLiteral "vertical";
    reverse = true;
    fixed-height = true;
    fixed-columns = true;
    cursor = "default";
    background-color = mkLiteral "transparent";
    text-color = foreground-colour;
  };

  scrollbar = {
    handle-width = mkLiteral "5px";
    handle-color = foreground-colour;
    border-radius = mkLiteral "10px";
    background-color = alternate-background;
  };

  # Elements

  element = {
    enabled = true;
    orientation = mkLiteral "vertical";
    spacing = mkLiteral "0px";
    padding = mkLiteral "0px";
    border-radius = mkLiteral "20px";
    cursor = mkLiteral "pointer";
    background-color = mkLiteral "transparent";
    text-color = foreground-colour;
  };

  "element selected.normal" = {
    background-color = selected-normal-background;
    text-color = background-colour;
  };

  element-icon = {
    size = mkLiteral "33%";
    cursor = mkLiteral "inherit";
    border-radius = mkLiteral "0px";
    background-color = mkLiteral "transparent";
    text-color = mkLiteral "inherit";
  };

  element-text = {
    vertical-align = mkLiteral "0.5";
    horizontal-align = mkLiteral "0.5";
    padding = mkLiteral "10px";
    cursor = mkLiteral "inherit";
    background-color = mkLiteral "transparent";
    text-color = mkLiteral "inherit";
  };
}
