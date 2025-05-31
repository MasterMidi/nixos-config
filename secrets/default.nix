{inputs,...}:{
	imports = [
		./system
	];

	home-manager = {
		sharedModules = [inputs.sops-nix.homeManagerModules.sops];
		users.michael.imports = [./users];
	};
}
