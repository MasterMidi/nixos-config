{ ... }:
{
  flake.nixosModules.thunderbird =
    { config, ... }:
    {
      sops.secrets.THUNDERBIRD_MICHAEL_PASSWORD = {
        sopsFile = ../../secrets/thunderbird.sops.yaml;
        owner = config.users.users.michael.name;
        group = config.users.users.michael.group;
        mode = "0400";
      };
    };

  flake.homeModules.thunderbird =
    { osConfig, pkgs, ... }:
    let
      address = "michael@michael-graversen.dk";
      host = "mail.mgrlab.dk";
      encodedAddress = "michael%40michael-graversen.dk";
      imapUri = "imap://${encodedAddress}@${host}";
      profile = "michael";
      passwordCommand = [
        "${pkgs.coreutils}/bin/cat"
        osConfig.sops.secrets.THUNDERBIRD_MICHAEL_PASSWORD.path
      ];
      thunderbirdAccount = {
        enable = true;
        profiles = [ profile ];
      };
    in
    {
      programs.thunderbird = {
        enable = true;
        profiles.${profile} = {
          isDefault = true;
          settings = {
            "calendar.timezone.local" = "Europe/Copenhagen";
            "calendar.timezone.useSystemTimezone" = true;
          };
        };
      };

      # Thunderbird currently ignores passwordCommand and prompts on first use.
      accounts.email.accounts.${address} = {
        primary = true;
        inherit address passwordCommand;
        userName = address;
        realName = "Michael Andreas Graversen";
        folders = {
          drafts = "Drafts";
          sent = "Sent Items";
          trash = "Deleted Items";
        };
        imap = {
          inherit host;
          port = 993;
          authentication = "plain";
          tls.enable = true;
          tls.useStartTls = false;
        };
        smtp = {
          inherit host;
          port = 465;
          authentication = "plain";
          tls.enable = true;
          tls.useStartTls = false;
        };
        thunderbird = thunderbirdAccount // {
          settings = id: {
            "mail.server.server_${id}.check_new_mail" = true;
            "mail.server.server_${id}.max_cached_connections" = 5;
            "mail.server.server_${id}.moveTargetMode" = 1;
            "mail.server.server_${id}.namespace.personal" = "\"\"";
            "mail.server.server_${id}.spamActionTargetAccount" = imapUri;
            "mail.server.server_${id}.spamActionTargetFolder" = "${imapUri}/Junk Mail";
            "mail.server.server_${id}.timeout" = 29;
            "mail.server.server_${id}.trash_folder_name" = "Deleted Items";
            "mail.smtpserver.smtp_${id}.description" = address;
          };
          perIdentitySettings = id: {
            "mail.identity.id_${id}.attach_signature" = false;
            "mail.identity.id_${id}.attach_vcard" = false;
            "mail.identity.id_${id}.catchAll" = false;
            "mail.identity.id_${id}.doBcc" = false;
            "mail.identity.id_${id}.draft_folder" = "${imapUri}/Drafts";
            "mail.identity.id_${id}.drafts_folder_picker_mode" = "0";
            "mail.identity.id_${id}.fcc_folder" = "${imapUri}/Sent Items";
            "mail.identity.id_${id}.fcc_folder_picker_mode" = "1";
            "mail.identity.id_${id}.htmlSigFormat" = false;
            "mail.identity.id_${id}.reply_on_top" = 1;
            "mail.identity.id_${id}.sig_bottom" = true;
            "mail.identity.id_${id}.stationery_folder" = "${imapUri}/Templates";
            "mail.identity.id_${id}.tmpl_folder_picker_mode" = "0";
          };
        };
      };

      accounts.calendar.accounts."Stalwart Calendar (${address})" = {
        remote = {
          type = "caldav";
          url = "https://${host}/dav/cal/${encodedAddress}/default/";
          userName = address;
          inherit passwordCommand;
        };
        thunderbird = thunderbirdAccount // {
          color = "#FFCCCC";
        };
      };

      accounts.contact.accounts."Stalwart Address Book (${address})" = {
        remote = {
          type = "carddav";
          url = "https://${host}/dav/card/${encodedAddress}/default/";
          userName = address;
          inherit passwordCommand;
        };
        thunderbird = thunderbirdAccount;
      };
    };
}
