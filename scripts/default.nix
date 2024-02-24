{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "switch" (builtins.readFile ./switch.sh))
    (pkgs.writeShellScriptBin "dvt" ''
         #!${pkgs.stdenv.shell}
      nix flake init -t "github:the-nix-way/dev-templates#$1"
      direnv allow
    '')
  ];
}
