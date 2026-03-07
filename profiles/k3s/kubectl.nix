{ self, pkgs, config, lib, ... }:
{
  environment.systemPackages = with pkgs; [ kubectl ];

  # allow for both manual and managed configs
  environment.sessionVariables = {
    KUBECONFIG = "$HOME/.kube/config:${config.sops.templates.kubeconfig-andromeda.path}";
  };

  sops.secrets = {
    K3S_ANDROMEDA_CA.sopsFile = ./secrets/k3s.yaml; 
    K3S_ANDROMEDA_CERT.sopsFile = ./secrets/k3s.yaml;
    K3S_ANDROMEDA_KEY.sopsFile = ./secrets/k3s.yaml;
  };

  sops.templates.kubeconfig-andromeda = {
    owner = "michael";
    mode = "0600";
    file = (pkgs.formats.yaml {}).generate "kubeconfig-andromeda.yaml" {
      apiVersion = "v1";
      kind = "Config";
      clusters = [
        {
          name = "default";
          cluster = {
            certificate-authority-data = config.sops.placeholder.K3S_ANDROMEDA_CA;
            server = "https://andromeda:6443";
          };
        }
      ];
      users = [
        {
          name = "default";
          user = {
            client-certificate-data = config.sops.placeholder.K3S_ANDROMEDA_CERT;
            client-key-data = config.sops.placeholder.K3S_ANDROMEDA_KEY;
          };
        }
      ];
      contexts = [
        {
          name = "default";
          context = {
            cluster = "default";
            user = "default";
          };
        }
      ];
    };
  };  
}
