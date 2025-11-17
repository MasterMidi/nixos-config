{ pkgs, ... }:
{
  home.packages = with pkgs; [
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
  ];

  home.file.".local/share/nautilus/scripts/set-as-wallpaper" = {
    executable = true;
    text = # bash
      ''
        #!/bin/sh
        ${pkgs.swww}/bin/swww img "$1" --transition-step 50 --transition-fps 200 --transition-type any --outputs "$OUTPUT_DISPLAY"
      '';
  };
}
