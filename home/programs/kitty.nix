{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
		shellIntegration.enableBashIntegration = false; # When true, makes starship fail on first load for some reason
    theme = "Gruvbox Material Dark Hard";
		font = {
			name = "MesloLGS";
			package = pkgs.meslo-lgs-nf;
			size = 10;
		};
  };
}
