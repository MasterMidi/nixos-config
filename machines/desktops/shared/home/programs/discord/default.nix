{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    (discord-canary.override {
      withVencord = true;
    })
  ];

  xdg.configFile."Vencord/settings/quickCss.css".text = (import ./discordcss.nix) config.colorScheme.palette;
}
