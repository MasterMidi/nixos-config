# Based on this comment: https://github.com/longhorn/longhorn/issues/2166#issuecomment-2994323945
{ ... }:
{
  flake.nixosModules.k8s-longhorn =
    { pkgs, config, ... }:
    {
      environment.systemPackages = with pkgs; [
        nfs-utils
        xfsprogs
      ];
      services.openiscsi = {
        enable = true;
        name = "${config.networking.hostName}-initiatorhost";
      };
      systemd.services.iscsid.serviceConfig = {
        PrivateMounts = "yes";
        BindPaths = "/run/current-system/sw/bin:/bin";
      };
      systemd.tmpfiles.rules = [
        "L /usr/bin/mount - - - - /run/current-system/sw/bin/mount"
      ];
      boot.kernelModules = [ "dm_crypt" ];
    };
}
