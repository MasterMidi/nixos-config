let
  pkgs = import <nixpkgs> {};
  nerdfix = pkgs.nerdfix;
in
pkgs.mkShell {
  buildInputs = [
    nerdfix
  ];
}
