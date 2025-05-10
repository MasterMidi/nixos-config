{pkgs, ...}: {
  home-manager.users.michael = {
    imports = [
      ./hyprland
      ./programs
      ./services
      ./theme
      ./default-apps.nix
    ];

    services.mpris-proxy.enable = true; # media player mpris proxy
    services.playerctld.enable = true; # media player control

    home.packages = with pkgs; [
      playerctl

      # gnome
      nautilus-open-any-terminal
      sushi
      file-roller # GNOME archive manager
      nautilus-python
      (nautilus.overrideAttrs (super: {
        buildInputs =
          super.buildInputs
          ++ (with gst_all_1; [
            gst-plugins-good
            gst-plugins-bad
          ]);
      }))

      # Tools
      ventoy-full
      xdg-utils
      envsubst
      jq
      tldr
      hyprpicker
      libnotify
      magic-wormhole-rs
      trash-cli
    ];
  };
}
