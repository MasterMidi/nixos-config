# https://codeberg.org/wolfangaukang/nix-agordoj/src/branch/main/home/users/bjorn/settings/firefox/default.nix
{
  pkgs,
  inputs,
  config,
  ...
}: {
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = with pkgs.nur.repos; [
      wolfangaukang.vdhcoapp
    ];
    profiles.default = {
      name = "Default";
      path = "nix.default";
      isDefault = true;
      settings = {
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

        # For Firefox GNOME theme:
        "browser.tabs.drawInTitlebar" = true;
        "browser.theme.dark-private-windows" = false;
        "browser.uidensity" = 0;
        "layers.acceleration.force-enabled" = true;
        "svg.context-properties.content.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "widget.gtk.rounded-bottom-corners.enabled" = true;
        "gnomeTheme.normalWidthTabs" = true;
      };
      extraConfig = builtins.readFile "${inputs.betterfox}/user.js";
      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";
        @import "firefox-gnome-theme/theme/colors/dark.css";
      '';
      userContent = ''
        @import "firefox-gnome-theme/userContent.css";
      '';
    };
  };

  home.file.".mozilla/firefox/${config.programs.firefox.profiles.default.path}/chrome/firefox-gnome-theme".source = inputs.firefox-gnome-theme;
}
