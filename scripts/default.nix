{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "switch" (builtins.readFile ./switch.sh))
  ];
}