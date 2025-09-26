{...}: {
  nix = {
    # Resource usage and management
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
  };
}
