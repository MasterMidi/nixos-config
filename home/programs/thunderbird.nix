{
  config,
  inputs,
  ...
}: {
  programs.thunderbird = {
    enable = true;
    profiles."nix.default" = {
      isDefault = true;
      settings = {
        # For Thunderbird GNOME theme:
        "svg.context-properties.content.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = ''
        @import "thunderbird-gnome-theme/userChrome.css";
        @import "thunderbird-gnome-theme/theme/colors/dark.css";
      '';
      userContent = ''
        @import "thunderbird-gnome-theme/userContent.css";
      '';
    };
  };
  home.file.".thunderbird/${config.programs.thunderbird.profiles."nix.default".name}/chrome/thunderbird-gnome-theme".source = inputs.thunderbird-gnome-theme;
}
