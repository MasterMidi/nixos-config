{ pkgs, lib, ... }: {
  helm.releases.longhorn = {
    namespace = "longhorn-system";
    chart = pkgs.fetchHelm {
      repo = "https://charts.longhorn.io";
      chart = "longhorn";
      version = "1.11.0";
      sha256 = "sha256-s1UBZTlU/AW6ZQmqN9wiQOA76uoWgCBGhenn9Hx3DCQ=";
    };

    
  };
}
