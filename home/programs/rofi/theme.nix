{config, ...}:
with config.colorScheme.palette; let
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
    # properties for window widget
    transparency = "real";
    location = mkLiteral "center";
    anchor = mkLiteral "center";
    fullscreen = false;
    width = mkLiteral "800px";

    # properties for all widgets
    enabled = true;
    margin = mkLiteral "0px";
    padding = mkLiteral "0px";
    border = mkLiteral "0px solid";
    border-radius = mkLiteral "10px";
    border-color = border-colour;
    cursor = "default";
    background-color = background-colour;
  };

  # Main Box
  mainbox = {
    enabled = true;
    padding = "4px";
    border-radius = mkLiteral "11px";
    background-image = mkLiteral "linear-gradient(45, #${base0D}, #${base0B})";
    children = map mkLiteral ["borderbox"];
  };

  borderbox = {
    spacing = mkLiteral "10px";
    margin = mkLiteral "0px";
    padding = mkLiteral "10px";
    border = mkLiteral "4px solid";
    border-radius = mkLiteral "10px";
    border-color = mkLiteral "transparent";
    background-color = background-colour;
    children = map mkLiteral ["inputbar" "message" "custombox"];
  };

  # A Custom Box
  custombox = {
    spacing = mkLiteral "10px";
    background-color = background-colour;
    text-color = foreground-colour;
    orientation = mkLiteral "horizontal";
    children = map mkLiteral ["mode-switcher" "listview"];
  };

  # Inputbar
  inputbar = {
    enabled = true;
    spacing = mkLiteral "10px";
    margin = mkLiteral "0px";
    padding = mkLiteral "8px 12px";
    border = mkLiteral "0px solid";
    border-radius = mkLiteral "8px";
    border-color = border-colour;
    background-color = alternate-background;
    text-color = foreground-colour;
    children = map mkLiteral ["textbox-prompt-colon" "entry"];
  };

  prompt = {
    enabled = true;
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  textbox-prompt-colon = {
    enabled = true;
    padding = mkLiteral "5px 0px";
    expand = false;
    str = " ";
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  entry = {
    enabled = true;
    padding = mkLiteral "5px 0px";
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
    cursor = mkLiteral "text";
    placeholder = "Search...";
    placeholder-color = mkLiteral "inherit";
  };

  num-filtered-rows = {
    enabled = true;
    expand = false;
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  textbox-num-sep = {
    enabled = true;
    expand = false;
    str = "/";
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  num-rows = {
    enabled = true;
    expand = false;
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  case-indicator = {
    enabled = true;
    background-color = mkLiteral "inherit";
    text-color = mkLiteral "inherit";
  };

  # Listview
  listview = {
    enabled = true;
    columns = 1;
    lines = 8;
    cycle = true;
    dynamic = true;
    scrollbar = true;
    layout = mkLiteral "vertical";
    reverse = false;
    fixed-height = true;
    fixed-columns = true;

    spacing = mkLiteral "5px";
    margin = mkLiteral "0px";
    padding = mkLiteral "0px";
    border = mkLiteral "0px solid";
    border-radius = mkLiteral "0px";
    border-color = border-colour;
    background-color = mkLiteral "transparent";
    text-color = foreground-colour;
    cursor = "default";
  };

  scrollbar = {
    handle-width = mkLiteral "5px";
    handle-color = handle-colour;
    border-radius = mkLiteral "10px";
    background-color = alternate-background;
  };

  # Elements
  element = {
    enabled = true;
    spacing = mkLiteral "10px";
    margin = mkLiteral "0px";
    padding = mkLiteral "10px";
    border = mkLiteral "0px solid";
    border-radius = mkLiteral "8px";
    border-color = border-colour;
    background-color = mkLiteral "transparent";
    text-color = foreground-colour;
    cursor = "pointer";
  };

  "element normal.normal" = {
    background-color = normal-background;
    text-color = normal-foreground;
  };

  "element normal.urgent" = {
    background-color = urgent-background;
    text-color = urgent-foreground;
  };

  "element normal.active" = {
    background-color = active-background;
    text-color = active-foreground;
  };

  "element selected.normal" = {
    background-color = selected-normal-background;
    text-color = selected-normal-foreground;
  };

  "element selected.urgent" = {
    background-color = selected-urgent-background;
    text-color = selected-urgent-foreground;
  };

  "element selected.active" = {
    background-color = selected-active-background;
    text-color = selected-active-foreground;
  };

  "element alternate.normal" = {
    background-color = alternate-normal-background;
    text-color = alternate-normal-foreground;
  };

  "element alternate.urgent" = {
    background-color = alternate-urgent-background;
    text-color = alternate-urgent-foreground;
  };

  "element alternate.active" = {
    background-color = alternate-active-background;
    text-color = alternate-active-foreground;
  };

  element-icon = {
    background-color = mkLiteral "transparent";
    text-color = mkLiteral "inherit";
    size = mkLiteral "24px";
    cursor = mkLiteral "inherit";
  };

  element-text = {
    background-color = mkLiteral "transparent";
    text-color = mkLiteral "inherit";
    highlight = mkLiteral "inherit";
    cursor = mkLiteral "inherit";
    vertical-align = mkLiteral "0.5";
    horizontal-align = mkLiteral "0.0";
  };

  # Mode Switcher
  mode-switcher = {
    enabled = true;
    expand = false;
    orientation = mkLiteral "vertical";
    spacing = mkLiteral "10px";
    margin = mkLiteral "0px";
    padding = mkLiteral "0px 0px";
    border = mkLiteral "0px solid";
    border-radius = mkLiteral "0px";
    border-color = border-colour;
    background-color = mkLiteral "transparent";
    text-color = foreground-colour;
  };

  button = {
    padding = mkLiteral "0px 20px 0px 20px";
    border = mkLiteral "0px solid";
    border-radius = mkLiteral "8px";
    border-color = border-colour;
    background-color = alternate-background;
    text-color = mkLiteral "inherit";
    vertical-align = mkLiteral "0.5";
    horizontal-align = mkLiteral "0.0";
    cursor = mkLiteral "pointer";
  };

  "button selected" = {
    background-color = selected-normal-background;
    text-color = selected-normal-foreground;
  };

  # Message
  message = {
    enabled = true;
    margin = mkLiteral "0px";
    padding = mkLiteral "0px";
    border = mkLiteral "0px solid";
    border-radius = mkLiteral "0px 0px 0px 0px";
    border-color = border-colour;
    background-color = mkLiteral "transparent";
    text-color = foreground-colour;
  };

  textbox = {
    padding = mkLiteral "12px";
    border = mkLiteral "0px solid";
    border-radius = mkLiteral "8px";
    border-color = border-colour;
    background-color = alternate-background;
    text-color = foreground-colour;
    vertical-align = mkLiteral "0.5";
    horizontal-align = mkLiteral "0.0";
    highlight = mkLiteral "none";
    placeholder-color = foreground-colour;
    blink = true;
    markup = true;
  };

  error-message = {
    padding = mkLiteral "10px";
    border = mkLiteral "2px solid";
    border-radius = mkLiteral "8px";
    border-color = border-colour;
    background-color = background-colour;
    text-color = foreground-colour;
  };
}
