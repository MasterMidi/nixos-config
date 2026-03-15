{ inputs, ... }:
{
  imports = [ inputs.devshell.flakeModule ];
  perSystem =
    { pkgs, lib, ... }:
    {
      formatter = pkgs.nixfmt-tree;
      devshells.default = {
        devshell = {
          name = "nixos-config";
          packages = with pkgs; [
            nixfmt
            nixfmt-tree
            nerdfix # fix nerdfont symbols in text files
            nurl
            nix-prefetch # prefetch urls to get hash
            nix-tree # visualize nix store
            nix-output-monitor # monitor nix build output
            nix-index # prebuilt-index nix store
            nix-melt # view flake.lock files
            nix-init # quick start to packaging projects
            statix # find anti-patterns in nix code
            nix-du # disk usage of nix store
            nixos-generators
            nix-inspect

            # secret management
            sops
            ssh-to-age

            flake-checker # healthcheck for flake.lock files
            deploy-rs # deploy nixos to remote servers

            nixos-facter

            (pkgs.writeTextDir "share/bash-completion/completions/dply" ''
              _dply_completion() {
                local cur prev flakeref target_prefix nodes completions

                cur="''${COMP_WORDS[COMP_CWORD]}"
                prev="''${COMP_WORDS[COMP_CWORD-1]}"

                if [[ COMP_CWORD -eq 1 ]]; then
                  if [[ "$cur" == *#* ]]; then
                    flakeref="''${cur%%#*}"
                    target_prefix="''${cur##*#}"

                    if [[ -z "$flakeref" ]]; then
                      flakeref="."
                    fi

                    nodes=$(nix eval --json "$flakeref#deploy.nodes" --apply 'builtins.attrNames' 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[]' 2>/dev/null)

                    if [[ -n "$nodes" ]]; then
                      for node in $nodes; do
                        completions="$completions ''${flakeref}#''${node}"
                      done
                      COMPREPLY=( $(compgen -W "$completions" -- "$cur") )
                    else
                      COMPREPLY=()
                    fi
                  else
                    COMPREPLY=( $(compgen -f -- "$cur") )
                  fi
                else
                  COMPREPLY=( $(compgen -f -- "$cur") )
                fi
              }

              # Bind the function to the command
              complete -o default -o bashdefault -F _dply_completion dply
            '')
          ];

          interactive.dply-completion.text = ''
            _dply_completions() {
              # $2 is the standard bash completion argument for the current word
              local cur="$2"

              # CACHING: Only run 'nix eval' the very first time you press TAB.
              # This prevents the terminal from hanging on subsequent tab presses.
              if [ -z "''${_DPLY_NODES_CACHE-}" ]; then
                _DPLY_NODES_CACHE=$(${pkgs.nix}/bin/nix eval --json .#deploy.nodes --apply builtins.attrNames 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[]' 2>/dev/null)
              fi

              # Build the list of options prefixed with .#
              local opts=""
              for n in $_DPLY_NODES_CACHE; do
                opts="$opts .#$n"
              done

              # Let compgen filter the cached options based on what the user typed
              COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
            }

            # Register the function to the dply command
            complete -F _dply_completions "dply .#"
          '';
        };

        commands = lib.mapAttrsToList (name: value: value // { name = name; }) {
          dply = {
            category = "deploy";
            help = "deploy to remote server";
            command = "deploy -s \"$@\" -- --log-format internal-json -v 2>&1 | nom --json";
          };
          evl = {
            category = "nixos";
            help = "evaluate nixos configuration";
            command = "nix eval --impure .#nixosConfigurations.$1";
          };
          usops = {
            category = "secrets";
            help = "updates all sops secrets with the current keys in .sops.yaml";
            command = ''
              echo "🔍 Searching for SOPS encrypted files..."

              # Find files containing SOPS MAC signatures (YAML, JSON, and ENV formats)
              files=$(${pkgs.ripgrep}/bin/rg -l '(mac: ENC\[|"mac": "ENC\[|sops_mac=ENC\[)')

              if [ -z "$files" ]; then
                echo "No SOPS encrypted files found."
                exit 0
              fi

              for file in $files; do
                echo "🔑 Updating keys for: $file"
                ${pkgs.sops}/bin/sops updatekeys -y "$file"
              done

              echo "✅ All secrets updated successfully!"
            '';
          };
        };
      };
    };
}
