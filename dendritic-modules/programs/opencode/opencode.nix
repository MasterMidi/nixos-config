{ ... }:
{
  flake.homeModules.opencode =
    { pkgs, ... }:
    {
      home.packages = [
        # Waiting for #554904 (https://github.com/NixOS/nixpkgs/pull/554904)
        (pkgs.openspec.overrideAttrs (
          finalAttrs: _previousAttrs: {
            version = "1.10.0";

            src = pkgs.fetchFromGitHub {
              owner = "Fission-AI";
              repo = "OpenSpec";
              tag = "v${finalAttrs.version}";
              hash = "sha256-2wD99+Ma1VZKWG7CJeHDbuT3Td40b/4o0TDKEyQNzBQ=";
            };

            pnpmDeps = pkgs.fetchPnpmDeps {
              inherit (finalAttrs) pname version src;
              pnpm = pkgs.pnpm_10;
              fetcherVersion = 3;
              hash = "sha256-n+tFm3GvMV3vH2A+1LTJbqxzgk5wOCJ7kng/0y56Zlk=";
            };
          }
        ))
      ];

      programs.opencode =
        let
          # opencode 2.2.5 in nixpkgs records a stale node_modules hash that
          # was computed before the bun 1.4.4 bump, so the fixed-output
          # derivation fails with a hash mismatch
          # (https://github.com/NixOS/nixpkgs/issues/582673, fix PR
          # https://github.com/NixOS/nixpkgs/pull/582675 not merged yet).
          # Substitute the hash bun 1.4.4 actually produces on x86_64-linux.
          # The version guard makes this a no-op once nixpkgs moves on.
          # TODO: remove when the fix reaches nixos-unstable.
          opencode =
            if pkgs.opencode.version == "2.2.5" && pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
              pkgs.opencode.overrideAttrs (old: {
                node_modules = old.node_modules.overrideAttrs (_: {
                  outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
                });
              })
            else
              pkgs.opencode;
        in
        {
          package = opencode;
          enable = true;
          settings = {
            plugins = [ "@slkiser/opencode-quota@6.0.0" ];
            model = "mistral/zai-glm-5-3";
            default_agent = "learn";
            agents = {
              title.model = "mistral/zai-glm-5-3-flash";
              explore.model = "mistral/zai-glm-5-3-flash";
              general.model = "mistral/zai-glm-5-3";
            };
          };
          # OpenCode 2 ignores tui.json and manages terminal plugins in its own
          # app-owned cli.json, so programs.opencode.tui is not used here.
          agents = ./agents;
        };
      xdg.configFile."opencode/opencode-quota/settings.jsonc".text = builtins.toJSON {
        # opencode-quota 6.x settings (OpenCode 2 plugin API)
        sidebar.show = true;
        collapsed.show = false;
        statusLine.show = true;
        toast.show = false;
        words.percent = "remaining";

        # Track the Mistral connection instead of OpenAI. Mistral has no
        # built-in quota provider; /quota_usage still reports its tokens/cost.
        providers.off = [ "openai" ];
        context = ''
          # Version control

          Use `jj` exclusively for all version-control operations. Never run `git` directly; if a Git subcommand is necessary, invoke it only as `jj git ...`. Prefer native `jj` commands for status, diffs, history, commits, and other VCS work. Apply this rule in every repository and to any delegated agent, even when project instructions show direct `git` commands.
        '';
      };
    };
}
