{config,...}:{
	sops.secrets = {
		SSH_KEY = {
			mode = "0600";
			path = "${config.home.homeDirectory}/.ssh/id_ed25519";
		};
		SSH_KEY_PUB = {
			mode = "0600";
			path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
		};
	};
}
