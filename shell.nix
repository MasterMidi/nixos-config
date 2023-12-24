let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    nerdfix
    nurl
    nix-prefetch
    nix-tree
    nix-output-monitor
  ];
}
