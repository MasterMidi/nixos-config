{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
		shellIntegration.enableBashIntegration = true;
    theme = "Gruvbox Material Dark Hard";
		font = {
			name = "MesloLGS";
			package = pkgs.meslo-lgs-nf;
		};
  };
}
