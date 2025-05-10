{
  pkgs,
  inputs,
  ...
}: let
  # spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  # imports = [inputs.spicetify-nix.homeManagerModules.default];

  home.packages = with pkgs; [
    spotify
  ];

  # programs.spicetify = {
  #   enable = false;
  #   theme = spicePkgs.themes.onepunch;
  #   colorScheme = "gruvbox";

  #   enabledExtensions = with spicePkgs.extensions; [
  #     fullAppDisplay
  #     shuffle # shuffle+
  #     hidePodcasts
  #   ];
  # };
}
