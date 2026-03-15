{ ... }:
{
  flake.nixosModules.hyprlock =
    { ... }:
    {
      # Allow hyprlock to lock the screen
      security.pam.services.hyprlock.text = "auth include login";
    };

  flake.homeModules.hyprlock = { ... }: { };
}
