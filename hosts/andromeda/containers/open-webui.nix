{ config, ... }:
{
  virtualisation.oci-containers.compose.mediaserver.containers.open-webui = {
    image = "ghcr.io/open-webui/open-webui:main";
    networking = {
      networks = [ "default" ];
      aliases = [ "open-webui" ];
    };
    volumes = [
      "/mnt/ssd/services/open-webui/data:/app/backend/data"
    ];
    environment = {
      ENABLE_OAUTH_SIGNUP = "true";
      OAUTH_CLIENT_ID = "84293fc2-931e-46c5-bfa2-12bcb5bd7c35";
      OAUTH_PROVIDER_NAME = "Pocket ID";
      OPENID_PROVIDER_URL = "https://oidc.mgrlab.dk/.well-known/openid-configuration";
      OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "true";

      # For group management, you can use the following variables:
      ENABLE_OAUTH_ROLE_MANAGEMENT = "true";
      ENABLE_OAUTH_GROUP_MANAGEMENT = "true";
      ENABLE_OAUTH_GROUP_CREATION = "true";
      # Make sure those match the ones you set up before in Pocket-ID
      OAUTH_ALLOWED_ROLES = "users, admin";
      OAUTH_ADMIN_ROLES = "admins";
      OAUTH_ROLES_CLAIM = "groups";
      OAUTH_SCOPES = "openid email profile groups";

      # Optional but useful variables:

      # So users are immediately added instead of being "pending"
      DEFAULT_USER_ROLE = "user";
      # Make Pocket-ID the only auth method
      # comment out if you need access via password
      ENABLE_LOGIN_FORM = "false";
      # Make Pocket-ID the source of truth for the profile pictures
      OAUTH_UPDATE_PICTURE_ON_LOGIN = "true";
    };
    secrets.env.OAUTH_CLIENT_SECRET.path = config.sops.secrets.OPEN_WEBUI_OIDC_CLIENT_SECRET.path;
  };
}
