{ pkgs, lib, ... }:

let
  namespace = "trek";
in
{
  kubernetes.resources.${namespace} = {
    Secret.trek-secret.stringData = {
      ENCRYPTION_KEY = "{{ secrets.trek_encryption_key }}";
      OIDC_CLIENT_SECRET = "{{ secrets.trek_oidc_client_secret }}";
    };

    PersistentVolumeClaim.trek-data = {
      spec = {
        accessModes = [ "ReadWriteOncePod" ];
        storageClassName = "longhorn-database";
        resources.requests.storage = "1Gi";
      };
    };

    PersistentVolumeClaim.trek-uploads = {
      spec = {
        accessModes = [ "ReadWriteOncePod" ];
        storageClassName = "longhorn";
        resources.requests.storage = "1Gi";
      };
    };
  };

  helm.releases.trek = {
    inherit namespace;

    chart = pkgs.fetchHelm {
      repo = "https://chart.liketrek.com";
      chart = "trek";
      version = "4.2.1";
      sha256 = "sha256-8kIQAqpFAYLQw24fsK/yCLtHYw7esDjQ+F0z2FAqo7Q=";
    };

    overrides = [
      (
        object:
        lib.recursiveUpdate object {
          metadata.namespace = namespace;
        }
      )
    ];

    values = {
      existingSecret = "trek-secret";

      env = {
        ALLOW_INTERNAL_NETWORK = "true";

        APP_URL = "https://trek.mgrlab.dk";
        OIDC_ISSUER = "https://oidc.mgrlab.dk";
        OIDC_CLIENT_ID = "7457823e-612b-4a51-9d71-f32ccdede539";
        OIDC_DISPLAY_NAME = "Pocket ID";
        OIDC_SCOPE = "openid email profile groups";
        OIDC_ADMIN_CLAIM = "groups";
        OIDC_ADMIN_VALUE = "admin";
      };

      persistence = {
        enabled = true;
        data.existingClaim = "trek-data";
        uploads.existingClaim = "trek-uploads";
      };

      resources = {
        limits.memory = "1Gi";
      };
    };
  };
}
