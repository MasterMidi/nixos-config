{ ... }:
{
  services.ssh-agent = {
    enable = true;
    # Keys live in the agent until the agent dies (reboot).
    # Combined with addKeysToAgent, you enter your passphrase once per boot.
    defaultMaximumIdentityLifetime = 8;
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      # Forward the local agent to remote hosts so you don't re-enter your
      # passphrase when hopping between machines. Only enable for trusted hosts.
      forwardAgent = true;
      addKeysToAgent = "yes";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
  };
}
