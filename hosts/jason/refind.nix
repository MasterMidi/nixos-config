{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.boot.loader.refind;

  efi = config.boot.loader.efi;

  refindBuilder = pkgs.substituteAll {
    src = ./refind-builder.py;

    isExecutable = true;

    inherit (pkgs) python3;

    nix = config.nix.package.out;

    timeout = if config.boot.loader.timeout != null then config.boot.loader.timeout else "";

    extraConfig = cfg.extraConfig;

    extraIcons = if cfg.extraIcons != null then cfg.extraIcons else "";

    inherit (pkgs) refind efibootmgr coreutils gnugrep gnused gawk utillinux;

    inherit (efi) efiSysMountPoint canTouchEfiVariables;
  };

in {

  options.boot.loader.refind = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = "Whether to enable the refind EFI boot manager";
    };

    # TODO: add limit to number of entries

    # TODO: add option to download theme from github

    # TODO: add setting option to set variables, like icon sizes

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration text appended to refind.conf";
    };

    extraIcons = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "A directory containing icons to be copied to 'extra-icons'";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (config.boot.kernelPackages.kernel.features or { efiBootStub = true; }) ? efiBootStub;

        message = "This kernel does not support the EFI boot stub";
      }
    ];

    boot.loader.grub.enable = mkDefault false;

    boot.loader.supportsInitrdSecrets = lib.mkForce false; # TODO what does this do ?

    boot.loader.efi.canTouchEfiVariables = true;

    system = {
      build.installBootLoader = refindBuilder;

      boot.loader.id = "refind";

      requiredKernelConfig = with config.lib.kernelConfig; [
        (isYes "EFI_STUB")
      ];
    };
  };

}

