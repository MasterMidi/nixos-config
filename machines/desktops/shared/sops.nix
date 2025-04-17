{...}: {
  sops.secrets = {
    SSH_KEY = {
      mode = "0600";
    };
    SSH_KEY_PUB = {
      mode = "0600";
    };
  };
}
