{...}: {
  security = {
    rtkit.enable = true;

    # Polkit for hyprland to get sudo password prompts
    polkit.enable = true;

    # Allow hyprlock to lock the screen
    pam.services.hyprlock.text = "auth include login";
  };

  services.gnome.gnome-keyring.enable = true;

  # View and manage keys and passwords
  programs.seahorse.enable = true;
}
