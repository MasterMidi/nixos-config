{config, ...}: let
  inherit (config.lib.formats.rasi) mkLiteral;
in {
  "*" = with config.colorScheme.palette; {
    background = mkLiteral "#${base00}";
    background-alt = mkLiteral "#${base01}";
    foreground = mkLiteral "#${base07}";
    selected = mkLiteral "#${base07}";
    active = mkLiteral "#${base07}";
    urgent = mkLiteral "#${base08}";
  };
}
