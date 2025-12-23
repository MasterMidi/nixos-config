{ ... }:
{
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    10250 # kubelet
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];

  networking.firewall.trustedInterfaces = [
    "cni0"
    "flannel.1"
  ];

  # This is essential for routing traffic from pods
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--debug"
      "--kubelet-arg=allowed-unsafe-sysctls=net.ipv4.conf.all.src_valid_mark"
      # "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];
  };

  virtualisation.containerd = {
    # enable = true;
    # Tell containerd about the nix-snapshotter plugin
    settings = {
      # "io.containerd.grpc.v1.cri".containerd.runtimes.runc.options.SystemdCgroup = true;
    };
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
}
