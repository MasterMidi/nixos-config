{
  config,
  pkgs,
  lib,
  ...
}:
{
  # 2. Open Firewall for HA (8123), OTBR Web (8081), and mDNS (5353)
  networking.firewall.allowedTCPPorts = [
    8123
    8081
    8080
    # 30081
  ];
  networking.firewall.allowedUDPPorts = [ 5353 ];

  # 3. CRITICAL: Enable IPv6 Forwarding (Required for Thread routing)
  boot.kernel.sysctl = {
    # Accept RA install
    "net.ipv6.conf.enu1u1.accept_ra" = 2;
    "net.ipv6.conf.enu1u1.accept_ra_rt_info_max_plen" = 64;

    # IP forward install
    "net.ipv6.conf.all.forwarding" = 1;
    # "net.ipv4.ip_forward" = 1;

    # Custom from Gemini
    "net.ipv4.conf.all.forwarding" = 1;
  };

  services.k3s = {
    # Add these flags to force IPv4 and specify the interface
    extraFlags = [
      "--node-ip=192.168.1.120" # Replace with your actual LAN IP
      "--flannel-iface=enu1u1" # Replace with your WiFi interface name
      "--disable-network-policy" # Disables the specific controller that is crashing

      # "--disable=traefik" # We don't need an Ingress controller
      "--disable=servicelb" # We use hostNetwork, so no LB needed
      "--disable=metrics-server" # Saves RAM
      "--disable-network-policy" # Fixes some flannel issues
    ];
  };

  # LOAD THESE MODULES for OTBR / Container NAT
  boot.kernelModules = [
    "br_netfilter"
    "iptable_nat"
    "iptable_filter"
    "iptable_mangle"
    "xt_NAT"
    "ipt_MASQUERADE"
    "ip6_tables"
    "ip6table_filter"
    "ip6table_nat" # Critical for Thread IPv6 NAT
    "ip6table_mangle"
    "tun"
  ];

  # Ensure the firewall doesn't block the container's internal bridges
  networking.firewall.checkReversePath = "loose";

  networking.nat.enable = true;
  networking.nat.externalInterface = "enu1u1";

  # 3. Enable legacy iptables compatibility (OTBR relies on this)
  networking.nftables.enable = false; # Ensure we aren't "nftables only"
  networking.firewall.enable = true;

  # boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  # This forces NixOS to include all legacy iptables/NAT modules in the build.
  virtualisation.docker.enable = true;
}
