{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    (discord.override {
      withVencord = true;
    })
  ];

  xdg.configFile."Vencord/settings/quickCss.css".text = (import ./discordcss.nix) config.colorScheme.palette;
}
