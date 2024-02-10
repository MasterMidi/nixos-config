let
  michaelDavid = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2Fa80uxY5jAy2xaIwjUIqvX+kFFD82PUwrE+lfSikv";
  piNixpi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILI6jSq53F/3hEmSs+oq9L4TwOo1PrDMAgcA1uo1CCV/";
  users = [michaelDavid piNixpi];

  david = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2Fa80uxY5jAy2xaIwjUIqvX+kFFD82PUwrE+lfSikv";
  nixpi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJAKCW7w/RB8KbQEZ3biIKEQu4PO3DIi9O/FDgDjlca";
  systems = [david nixpi];
in {
  "wifi-secret.age".publicKeys = [piNixpi nixpi];
  "secret1.age".publicKeys = [michaelDavid david];
  "secret2.age".publicKeys = users ++ systems;
}
