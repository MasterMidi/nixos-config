{
  pkgs,
  config,
  ...
}: {
  programs.btop = {
    enable = true;
    # package = pkgs.btop.overrideAttrs (
    #   old: {
    #     src = pkgs.fetchFromGitHub {
    #       repo = "btop";
    #       owner = "aristocratos";
    #       rev = "285fb215d12a5e0c686b29e1039027cbb2b246da";
    #       sha256 = "sha256-8nDX6aNuhBz7IRxrqItksWM4L+6geuVycQdwlpSQdg0=";
    #     };
    #   }
    # );
    settings = {
      color-theme = "gruvbox_material_dark";
      # color_theme = "base16";
      shown_boxes = "proc cpu gpu0 mem net";
      update_ms = 500;
      show_gpu_info = "on";
    };
  };

  xdg.configFile."btop/themes/base16.theme".text = (import ./btopTheme.nix) config.colorScheme;
}
