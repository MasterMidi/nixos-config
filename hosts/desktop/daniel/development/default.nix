{pkgs, ...}: {
  imports = [
    ./android.nix
  ];

  environment.systemPackages = with pkgs; [
    rust-bin.stable.latest.default
  ];
}
