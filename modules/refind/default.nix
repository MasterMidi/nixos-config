# https://gist.github.com/betaboon/97abed457de8be43f89e7ca49d33d58d
# TODO: resize background image to resolution (if provided)
# TODO: add limit to number of entries
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.boot.loader.refind;

  efi = config.boot.loader.efi;

  theme = cfg.theme;

  installPath = "${efi.efiSysMountPoint}/efi/refind";

  # Function to convert structured settings into extraConfig strings
  settingsToConfig = settings: concatStringsSep "\n" (mapAttrsToList (name: value: "${name} ${toString value}") settings);

  # Function to handle includes separately
  includesToConfig = includes: concatStringsSep "\n" (map (include: "include ${toString include}") includes);

  # Assuming theme provides a 'theme.conf' at its root
  defaultThemeInclude =
    if theme != null
    then ["themes/${theme.pname}/theme.conf"]
    else [];

  # Function to assemble extraConfig with newlines between sections
  assembleExtraConfig = parts: let
    filteredParts = filter (part: part != "") parts; # Remove empty parts
  in
    concatStringsSep "\n" filteredParts;

  copyThemeScript = pkgs.writeScriptBin "copy-refind-theme" ''
      #!${pkgs.stdenv.shell}
      set -euo pipefail
      themeSource=${theme}
      themeDestination=${installPath}/themes/${theme.pname}

    if [ -d "$themeDestination" ]; then
        rm -rf "$themeDestination"
      fi

      # Ensure the destination directory exists
      mkdir -p $themeDestination

      # Copy the theme files
      cp -r $themeSource/* $themeDestination/
  '';

  refindBuilder = pkgs.substituteAll {
    src = ./refind-builder.py;

    isExecutable = true;

    inherit (pkgs) python3;

    nix = config.nix.package.out;

    timeout =
      if config.boot.loader.timeout != null
      then config.boot.loader.timeout
      else "";

    # Merge settings and includes into extraConfig
    extraConfig = assembleExtraConfig [
      (includesToConfig (cfg.include ++ defaultThemeInclude))
      (settingsToConfig cfg.settings)
      cfg.extraConfig
    ];

    extraIcons =
      if cfg.extraIcons != null
      then cfg.extraIcons
      else "";

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

    settings = mkOption {
      type = types.attrs;
      default = {};
      example = {
        resolution = "3440 1440";
        big_icon_size = 128;
        small_icon_size = 48;
      };
      description = "Structured settings for rEFInd, converted to extraConfig format";
    };

    include = mkOption {
      type = types.listOf (types.either types.path types.str);
      default = [];
      example = [./theme.conf "/path/to/another/config.conf"];
      description = "List of external configuration files to include";
    };

    theme = mkOption {
      type = types.package;
      default = null;
      description = "The theme for rEFInd. Can be a Nix package or a URL to fetch the theme from.";
      example = pkgs.refind-theme-regular;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (config.boot.kernelPackages.kernel.features or {efiBootStub = true;}) ? efiBootStub;

        message = "This kernel does not support the EFI boot stub";
      }
    ];

    # Configuration that uses the theme
    environment.systemPackages = [pkgs.refind] ++ lib.optional (theme != null) theme;

    boot.loader.grub.enable = mkDefault false;

    boot.loader.supportsInitrdSecrets = lib.mkForce false;

    boot.loader.efi.canTouchEfiVariables = true;

    system = {
      build.installBootLoader = refindBuilder;

      boot.loader.id = "refind";

      requiredKernelConfig = with config.lib.kernelConfig; [
        (isYes "EFI_STUB")
      ];

      activationScripts.copyTheme = {
        text = "${copyThemeScript}/bin/copy-refind-theme";
        # deps = {"mount-boot"}; # Ensure /boot is mounted before copying
      };
    };

    systemd.tmpfiles.rules = [
      "d ${installPath}/themes/${theme.pname} 0755 root root - -"
    ];
  };
}
