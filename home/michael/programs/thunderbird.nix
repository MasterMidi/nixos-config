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

  accounts = {
    email.accounts = {
      "home@michael-graversen.dk" = rec {
        primary = true;
        address = "home@michael-graversen.dk";
        userName = "home@michael-graversen.dk";
        realName = "Michael Andreas Graversen";
        passwordCommand = "cat ${config.sops.secrets.HOME_MICHAEL_GRAVERSEN_DK.path}";
        signature.text = ''
          Mvh. ${realName}
        '';
        imap = {
          host = "mail.simply.com";
          port = 143;
          tls.useStartTls = true;
        };
        smtp = {
          host = "smtp.simply.com";
          port = 587;
          tls.useStartTls = true;
        };
        thunderbird = {
          enable = true;
          profiles = ["nix.default"];
        };
      };
      "michael-graversen@hotmail.com" = rec {
        address = "michael-graversen@hotmail.com";
        userName = "michael-graversen@hotmail.com";
        realName = "Michael Andreas Graversen";
        passwordCommand = "cat ${config.sops.secrets.MICHAEL_GRAVERSEN_HOTMAIL.path}";
        signature.text = ''
          Mvh. ${realName}
        '';
        flavor = "outlook.office365.com";
        thunderbird = {
          enable = true;
          profiles = ["nix.default"];
        };
      };
    };
    calendar.accounts = {
      "home@michael-graversen.dk" = {
        remote = {
          type = "caldav";
          userName = "home@michael-graversen.dk";
          remote = "https://dav.simply.com/calendars/home@michael-graversen.dk/home@michael-graversen.dk/";
          passwordCommand = "cat ${config.sops.secrets.HOME_MICHAEL_GRAVERSEN_DK.path}";
        };
      };
    };
  };
}
