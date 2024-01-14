{pkgs, ...}: {
  programs.btop = {
    enable = true;
    package = pkgs.btop.overrideAttrs (
      old: {
        src = pkgs.fetchFromGitHub {
          repo = "btop";
          owner = "aristocratos";
          rev = "285fb215d12a5e0c686b29e1039027cbb2b246da";
          sha256 = "sha256-8nDX6aNuhBz7IRxrqItksWM4L+6geuVycQdwlpSQdg0=";
        };
      }
    );
    settings = {
      color-theme = "gruvbox_dark_v2";
      shown_boxes = "proc cpu gpu0 mem net";
      update_ms = 500;
    };
  };
}
