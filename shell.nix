{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "nixos-config";
  buildInputs = with pkgs; [
    nixpkgs-fmt
    nerdfix
    nurl
    nix-prefetch
    nix-tree
    nix-output-monitor
    nix-index
    nix-melt # view flake.lock files
    nix-init # quick start to packaging projects
    statix # find anti-patterns in nix code
    nix-du # disk usage of nix store
    nixos-generators
  ];
}
