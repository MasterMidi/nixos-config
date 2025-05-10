{config, ...}: {
  programs.btop = {
    enable = true;
    settings = {
      # color-theme = "gruvbox_material_dark";
      color_theme = "base16";
      shown_boxes = "proc cpu gpu0 mem net";
      update_ms = 500;
      show_gpu_info = "on";
    };
  };

  xdg.configFile."btop/themes/base16.theme".text = (import ./btopTheme.nix) config.colorScheme;
}
