{ pkgs, ... }:
rec {
  kubernetes.resources.${helm.releases.obsidian-livesync.namespace}.Secret.obsidian-livesync-couchdb.stringData =
    {
      adminUsername = "{{ secrets.obsidian_livesync_couchdb_admin_username }}";
      cookieAuthSecret = "{{ secrets.obsidian_livesync_couchdb_cookie_auth_secret }}";
      adminPassword = "{{ secrets.obsidian_livesync_couchdb_admin_password }}";
      erlangCookie = "{{ secrets.obsidian_livesync_couchdb_erlang_cookie }}";
    };

  helm.releases.obsidian-livesync = {
    namespace = "default";
    chart = pkgs.fetchHelm {
      repo = "https://apache.github.io/couchdb-helm";
      chart = "couchdb";
      version = "4.6.3";
      sha256 = "sha256-DIwqYD+MipkZAu9uLd0PE8rYhL0pfzwN5B9xTkbyKOw=";
    };

    values = {
      createAdminSecret = false; # Manually create the secret instead
      couchdbConfig.couchdb.uuid = "5b5f7e6a-9ee8-4b4a-9dcd-6eeb7ea1e8e8";
      clusterSize = 1;
      persistentVolume.enabled = false;
    };
  };
}
