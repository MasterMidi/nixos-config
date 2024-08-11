{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kitty.terminfo # for kitty terminal ssh support
    btop # system monitor utility
    whereami # easily find nix store path for executable

    # Custom script to show file structure of a given package
    (pkgs.writeShellScriptBin "pkg-eval" ''
      # Get the list of registries and format it to only show the name after 'flake:'
      # Use gum to choose the registry
      REGISTRY_CHOICE=$(nix registry list | awk -F ' ' '{print $2}' | awk -F ':' '{print $2}' | sort | uniq | ${pkgs.gum}/bin/gum choose --header "choose flake registry" --limit 1)

      # Build the package using the selected registry
      PACKAGE=$(${pkgs.gum}/bin/gum spin --spinner dot --title "Building package from $REGISTRY_CHOICE..." --show-output -- nix build "$REGISTRY_CHOICE"#"$1" --print-out-paths --no-link)

      # Check if multiple paths are returned
      IFS=$'\n'
      read -r -d ''' -a PACKAGE_ARRAY <<< "$PACKAGE"
      if [ ''${#PACKAGE_ARRAY[*]} -eq 1 ]; then
      	# If only one path, call eza directly
      	${pkgs.eza}/bin/eza --tree --level 4 "''${PACKAGE_ARRAY[0]}"
      else
      	# If multiple paths, use gum to choose
      	CHOICE=$(${pkgs.gum}/bin/gum choose "''${PACKAGE_ARRAY[@]}")
      	${pkgs.eza}/bin/eza --tree --level 4 "$CHOICE"
      fi
    '')
  ];
}
