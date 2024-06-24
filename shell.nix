{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "nixos-config";
  buildInputs = with pkgs; [
    nixpkgs-fmt
    nerdfix # fix nerdfont symbols in text files
    nurl
    nix-prefetch # prefetch urls to get hash
    nix-tree # visualize nix store
    nix-output-monitor # monitor nix build output
    nix-index # prebuilt-index nix store
    nix-melt # view flake.lock files
    nix-init # quick start to packaging projects
    statix # find anti-patterns in nix code
    nix-du # disk usage of nix store
    nixos-generators
    nix-inspect
    sops # secret management
    flake-checker # healthcheck for flake.lock files
  ];
}
