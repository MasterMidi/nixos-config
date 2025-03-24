{pkgs, ...}: let
  deployAutoComplete = pkgs.writeShellScript "deploy-autocomplete" ''
    # Function to get NixOS configurations
    _get_nixos_configs() {
        # Remove brackets and quotes from the JSON array, then split into words
        nix eval .#nixosConfigurations --apply builtins.attrNames --json 2>/dev/null | \
            tr -d '[]"' | tr ',' ' '
    }

    # Autocomplete function
    _nixos_config_complete() {
        local cur=''${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(compgen -W "$(_get_nixos_configs)" -- "$cur"))
    }

    # Register the autocomplete function
    complete -F _nixos_config_complete dply
  '';
in {
  imports = [
    ./deployment.nix
    ./nix.nix
    ./packages.nix
    ./sops.nix
    ./system.nix
    ./users.nix
  ];

  programs.bash.blesh.enable = true;
  programs.bash.interactiveShellInit = ''
    . ${deployAutoComplete}
  '';

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "zip" ''
      ${pkgs.gnutar}/bin/tar cf - $1 -P | ${pkgs.pv}/bin/pv -s $(${pkgs.coreutils}/bin/du -sb $1 | ${pkgs.gawk}/bin/awk '{print $1}') | ${pkgs.gzip}/bin/gzip > $2.tar.gz
    '')
    (writeShellScriptBin "uzip" ''
      ${pkgs.pv}/bin/pv $1 | ${pkgs.gnutar}/bin/tar -x
    '')
    (writeShellScriptBin "rtc" ''
      # Check if any arguments were provided
      if [ $# -eq 0 ]; then
          echo "Usage: $0 command [arguments...]"
          echo "Example: $0 tar -xf some_file.tar"
          exit 1
      fi

      # Run the command in background
      "$@" &

      # Get the job ID of the last background process
      job_id=$!

      # Disown the process so it continues after terminal closes
      disown -h "$job_id"

      # Print confirmation message
      echo "Process started with PID $job_id and disowned"
      echo "It will continue running even if you disconnect"
    '')
  ];
}
