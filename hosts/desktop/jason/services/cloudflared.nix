{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [cloudflared];

  services.cloudflared = {
    enable = true;
    tunnels = {
      media_server = {
        default = "http_status:404";
        ingress = {};
        credentialsFile = "/home/michael/.cloudflared/d079f5fd-3d60-4c75-8ae4-34b15210876e.json";
      };
    };
  };
}
