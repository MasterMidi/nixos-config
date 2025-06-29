{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    port = 11434;
    host = "0.0.0.0"; # TODO: only listen on localhost and tailscale network
    openFirewall = true;
    acceleration = "rocm";
  };

  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];

}
