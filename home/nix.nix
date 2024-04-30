{
  lib,
  inputs,
  ...
}: {
  nix = {
    gc = {
      automatic = true;
      frequency = "daily";
      options = "--delete-older-than 7d";
    };

    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;
  };
}
