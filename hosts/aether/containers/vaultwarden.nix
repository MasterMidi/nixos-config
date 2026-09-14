{ config, ... }:
{
  virtualisation.oci-containers.compose.tunnel.containers = {
    vaultwarden = {
      image = "docker.io/vaultwarden/server:1.37.2-alpine";
      autoUpdate = "registry";
      networking = {
        networks = [ "default" ];
        aliases = [ "vaultwarden" ];
      };
      environment = {
        DOMAIN = "https://vaultwarden.mgrlab.dk";
        SIGNUPS_ALLOWED = "false";

        # PocketID callback: https://vaultwarden.mgrlab.dk/identity/connect/oidc-signin
        SSO_ENABLED = "true";
        SSO_ONLY = "false";
        SSO_SIGNUPS_MATCH_EMAIL = "true";
        SSO_AUTHORITY = "https://oidc.mgrlab.dk";
        SSO_SCOPES = "email profile groups offline_access";
        SSO_PKCE = "true";
        SSO_CLIENT_ID = "51aeacad-0814-4a30-83a4-3e9e43d4a5c0";
      };
      secrets.env.SSO_CLIENT_SECRET.path = config.sops.secrets.VAULTWARDEN_OIDC_CLIENT_SECRET.path;
      volumes = [
        "/mnt/ssd/services/vaultwarden/data:/data"
      ];
    };
  };
}
