{
  pkgs,
  config,
  ...
}: {
  programs.bat = {
    enable = true;
    config.theme = "base16";
    themes.base16.src = pkgs.writeText "base16.tmTheme" (import ./tmTheme.nix config.colorScheme);
  };
}
