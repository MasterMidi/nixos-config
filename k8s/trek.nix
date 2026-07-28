{ pkgs, lib, ... }:

let
  namespace = "trek";
in
{
  kubernetes.resources.${namespace} = {
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
      version = "3.4.1";
      sha256 = "sha256-FIwjcnjkrhaqZUtN8TZIqMzIG0N2+VMjSz6OvjIBnw0=";
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
      secretEnv = {
        ENCRYPTION_KEY = "7af32d40f9f1168f7730164beee86b269b802e840bb81e7c6369c67766866714";
        OIDC_CLIENT_SECRET = "uci5k1qf9DRk8D5H61T6qjQ8MC09hEru";
      };

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
