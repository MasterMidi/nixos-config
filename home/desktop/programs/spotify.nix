{
  pkgs,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  imports = [inputs.spicetify-nix.homeManagerModule];

  home.packages = with pkgs; [
    spotify
  ];

  programs.spicetify = {
    enable = false;
    theme = spicePkgs.themes.text;
    colorScheme = "gruvbox";

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle # shuffle+
      hidePodcasts
    ];
  };
}
