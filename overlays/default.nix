# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  # TODO: find out why the import parts makes callPackage disappear
  # additions = final: _prev: import ../pkgs {inherit final;};
  # additions = final: prev: import ../pkgs {pkgs = prev;};
  additions = final: _prev: {
    refindTheme.refind-minimal = final.callPackage ../pkgs/refind-minimal {};
    rofi-nerdy = final.callPackage ../pkgs/rofi-nerdy {};
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  # unstable-packages = final: _prev: {
  #   unstable = import inputs.nixpkgs-unstable {
  #     system = final.system;
  #     config.allowUnfree = true;
  #   };
  # };
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  legacy-packages = final: _prev: {
    legacy = import inputs.nixpkgs-legacy {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  chaotic-packages = final: _prev: {
    chaotic = import inputs.nixpkgs-chaotic.nixosModules.default {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  vscode-extensions = final: _prev: {
    vscode-extensions = import inputs.nix-vscode-extensions;
  };
}
