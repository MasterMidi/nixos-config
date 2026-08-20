{ ... }:
{
  flake.homeModules.opencode =
    { ... }:
    {
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
