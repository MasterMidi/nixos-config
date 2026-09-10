{ pkgs, ... }:

{
  terraform.required_providers.hcloud = {
    source = "hetznercloud/hcloud";
    version = "= ${pkgs.terraform-providers.hetznercloud_hcloud.version}";
  };

  resource.hcloud_primary_ip.aether_ipv4 = {
    name = "primary_ip-80960483";
    type = "ipv4";
    location = "fsn1";
    auto_delete = true;
    delete_protection = false;
    labels = { };

    lifecycle.prevent_destroy = true;
  };

  resource.hcloud_primary_ip.aether_ipv6 = {
    name = "primary_ip-80960484";
    type = "ipv6";
    location = "fsn1";
    auto_delete = true;
    delete_protection = false;
    labels = { };

    lifecycle.prevent_destroy = true;
  };

  resource.hcloud_server.aether = {
    name = "Aether";
    server_type = "cx22";
    image = "ubuntu-24.04";
    location = "fsn1";
    keep_disk = false;
    backups = false;
    labels = { };
    delete_protection = false;
    rebuild_protection = false;
    shutdown_before_deletion = false;

    public_net = [
      {
        ipv4_enabled = true;
        ipv4 = "\${hcloud_primary_ip.aether_ipv4.id}";
        ipv6_enabled = true;
        ipv6 = "\${hcloud_primary_ip.aether_ipv6.id}";
      }
    ];

    lifecycle = {
      prevent_destroy = true;
      ignore_changes = [ "public_net" ];
    };
  };

  resource.hcloud_ssh_key.michael = {
    name = "home@michael-graversen.dk";
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFj+oDZwuwmlh7dx9LYlSSMBZ29ejGJ5BFVD4ILx6aN";
    labels = { };

    lifecycle.prevent_destroy = true;
  };

  resource.hcloud_rdns.aether_ipv4 = {
    primary_ip_id = "\${hcloud_primary_ip.aether_ipv4.id}";
    ip_address = "\${hcloud_primary_ip.aether_ipv4.ip_address}";
    dns_ptr = "mail.mgrlab.dk";

    lifecycle.prevent_destroy = true;
  };

  resource.hcloud_rdns.aether_ipv6 = {
    primary_ip_id = "\${hcloud_primary_ip.aether_ipv6.id}";
    ip_address = "\${hcloud_primary_ip.aether_ipv6.ip_address}";
    dns_ptr = "mail.mgrlab.dk";

    lifecycle.prevent_destroy = true;
  };

  import = [
    {
      to = "hcloud_primary_ip.aether_ipv4";
      id = "80960483";
    }
    {
      to = "hcloud_primary_ip.aether_ipv6";
      id = "80960484";
    }
    {
      to = "hcloud_server.aether";
      id = "59714693";
    }
    {
      to = "hcloud_ssh_key.michael";
      id = "27116137";
    }
    {
      to = "hcloud_rdns.aether_ipv4";
      id = "p-80960483-138.199.154.23";
    }
    {
      to = "hcloud_rdns.aether_ipv6";
      id = "p-80960484-2a01:4f8:c17:3c6f::";
    }
  ];

  output.aether_server_id.value = "\${hcloud_server.aether.id}";
  output.aether_ipv4.value = "\${hcloud_primary_ip.aether_ipv4.ip_address}";
  output.aether_ipv6_network.value = "\${hcloud_primary_ip.aether_ipv6.ip_network}";
  output.aether_location.value = "\${hcloud_server.aether.location}";
  output.aether_server_type.value = "\${hcloud_server.aether.server_type}";
}
