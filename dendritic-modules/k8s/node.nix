{ ... }:
{
  flake.nixosModules.k3s-node =
    { ... }:
    {
      networking.firewall.allowedTCPPorts = [
        6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
        10250 # kubelet
        2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
        2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
      ];
      networking.firewall.allowedUDPPorts = [
        8472 # k3s, flannel: required if using multi-node for inter-node networking
      ];

      networking.firewall.trustedInterfaces = [
        "cni0"
        "flannel.1"
      ];

      boot.kernelModules = [ "vxlan" ];

      # This is essential for routing traffic from pods
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      # ensure we have cgroups https://docs.k3s.io/installation/requirements?os=pi#cgroups
      boot.kernelParams = [
        "cgroup_memory=1"
        "cgroup_enable=memory"
      ];

      services.k3s = {
        enable = true;
        extraFlags = [
          # "--debug"
          "--kubelet-arg=allowed-unsafe-sysctls=net.ipv4.ip_forward,net.ipv6.conf.all.forwarding,net.ipv4.conf.all.src_valid_mark"
          "--flannel-backend=vxlan"
          "--node-ip=192.168.1.139"
          "--disable-network-policy" # Needed, else no access to internet (or i just need some network policy changes, but this works for now)

          # Authentication
          # "--kube-apiserver-arg=oidc-issuer-url=https://oidc.mgrlab.dk"
          # "--kube-apiserver-arg=oidc-client-id=3299125f-7187-4c2e-b5ba-ab0280f18f6c"
          # "--kube-apiserver-arg=oidc-username-claim=preferred_username"
          # "--kube-apiserver-arg=oidc-groups-claim=groups"
          # "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
        ];
      };

      ### Fix ipv6 resolution not working so use ipv4 ###

      # This replaces your DHCP-provided or other nameservers
      # with a static, IPv4-only list.
      networking.nameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];

      # Also, ensure IPv6 is not preferred for DNS if it's enabled
      # This might not be necessary if setting nameservers manually
      networking.dhcpcd.wait = "ipv4";

      # Flannel seems to be missing its subnet.env, envestigate why file is missing, but a workaround for now is to create it manually
      systemd.tmpfiles.rules = [
        "d /run/flannel 0755 root root -"
      ];
      # environment."/run/flannel/subnet.env".text = ''
      # FLANNEL_NETWORK=10.240.0.0/16
      # FLANNEL_SUBNET=10.240.0.1/24
      # FLANNEL_MTU=1450
      # FLANNEL_IPMASQ=true
      # '';
    };
}
