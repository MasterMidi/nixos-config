{
  pkgs,
  config,
  ...
}: {
  # TODO: update script only copy to clipboard if an item is selected in rofi
  home.packages = with pkgs; [
    (writeShellScriptBin "rofi-clipboard" ''
      nohup ${pkgs.ydotool}/bin/ydotoold --socket-path /tmp/ydotools & # Start ydotoold in the background
      ${pkgs.cliphist}/bin/cliphist list | ${config.programs.rofi.package}/bin/rofi -dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy # Copy the selected item to the clipboard
      ${pkgs.ydotool}/bin/ydotool key 29:1 42:1 47:1 47:0 42:0 29:0 # Ctrl+Shift+V
      pkill ydotool # Kill ydotoold
    '')
  ];
}
