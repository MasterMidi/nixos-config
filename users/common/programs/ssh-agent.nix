{ ... }:
{
  services.ssh-agent = {
    enable = true;
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      # Forward the local agent to remote hosts so you don't re-enter your
      # passphrase when hopping between machines. Only enable for trusted hosts.
      ForwardAgent = true;
      AddKeysToAgent = "yes";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
  };
}
