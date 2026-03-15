{ ... }:
rec {
  # imports = [
  #   flake.flakeModules.nix-builder
  # ];
  flake.flakeModules.nix-builder =
    { config, ... }:
    let
      cfg = config.builder;
    in
    {
      options = { };
      config = { };
    };
}
