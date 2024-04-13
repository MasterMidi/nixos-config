# dvd and dvt stolen from https://determinate.systems/posts/nix-direnv/
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "extract" (builtins.readFile ./extract.sh))
    (pkgs.writeShellScriptBin "switch" (builtins.readFile ./switch.sh))
    (pkgs.writeShellScriptBin "dvt" ''
      #!${pkgs.stdenv.shell}
      nix flake init -t "github:the-nix-way/dev-templates#$1"
      direnv allow
    '')
    (pkgs.writeShellScriptBin "dvd" ''
      #!${pkgs.stdenv.shell}
      echo "use flake \"github:the-nix-way/dev-templates?dir=$1\"" >> .envrc
      direnv allow
    '')
  ];
}
