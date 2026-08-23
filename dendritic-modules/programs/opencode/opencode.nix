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
          plugin = [ "@slkiser/opencode-quota@4.8.2" ];
          default_agent = "learn";
          agent.explore.permission = {
            edit = "deny";
            bash = "deny";
          };
        };
        tui.plugin = [ "@slkiser/opencode-quota@4.8.2" ];
        agents = ./agents;
      };
      xdg.configFile."opencode/opencode-quota/quota-toast.json".text = builtins.toJSON {
        enabledProviders = [ "openai" ];
        formatStyle = "allWindows";
        percentDisplayMode = "remaining";

        tuiSidebarPanel.enabled = true;
        tuiPromptBar.enabled = true;
        tuiCompactStatus.enabled = false;
        enableToast = false;

        maintainerAnnouncements.enabled = false;
      };
    };
}
