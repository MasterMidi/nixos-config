{
  pkgs,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  imports = [inputs.spicetify-nix.homeManagerModule];

  programs.spicetify = {
    # enable = true;
    theme = spicePkgs.themes.text;
    colorScheme = "gruvbox";

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle # shuffle+ (special characters are sanitized out of ext names)
      hidePodcasts
    ];
  };
}
