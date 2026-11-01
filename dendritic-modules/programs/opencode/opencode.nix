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

      programs.opencode = {
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
      };
    };
}
