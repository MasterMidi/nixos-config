{
  pkgs,
  config,
  ...
}: let
  theme = config.colorScheme.palette;
in {
  home.packages = with pkgs; [
    (discord.override {
      withVencord = true;
    })
  ];

  xdg.configFile."Vencord/settings/quickCss.css".text = (import ./discordcss.nix) theme;
}
