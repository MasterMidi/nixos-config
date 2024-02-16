{...}: {
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      manager = {
        sort_by = "alphabetical";
        sort_reverse = true;
      };
    };
  };
}
