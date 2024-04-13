# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  # TODO: find out why the import parts makes callPackage disappear
  # additions = final: _prev: import ../pkgs {inherit final;};
  # additions = final: prev: import ../pkgs {pkgs = prev;};
  additions = final: _prev: {
    refindTheme.refind-minimal = final.callPackage ../pkgs/refind-minimal {};
    rofi-nerdy = final.callPackage ../pkgs/rofi-nerdy {};
    qbitmanage = final.callPackage ../pkgs/qbitmanage {};
    vscode-extensions = import inputs.nix-vscode-extensions;
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };
}
