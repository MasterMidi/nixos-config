{ pkgs, inputs, ... }:
{
	programs.vscode = {
		enable = true;
		package = pkgs.vscodium;
		enableUpdateCheck = false;
		userSettings = {
			"editor.wordWrap" = "on";
			"editor.fontFamily" = "MesloLGM";
			"editor.fontLigatures" = true;
			"files.autoSave" = "afterDelay";
			"git.autofetch" = true;
			"git.confirmSync" = false;
			"window.autoDetectColorScheme" = true;
			"window.titleBarStyle" = "custom";
			"workbench.colorTheme" = "One Dark Pro Mix";
			"workbench.iconTheme" = "material-icon-theme";
			"workbench.preferredDarkColorTheme" = "One Dark Pro Mix";
			"workbench.preferredHighContrastColorTheme" = "Default High Contrast Light";
			"workbench.settings.editor" = "json";
			"workbench.tree.indent" = 20;
		};
		keybindings = [
			{
				command = "workbench.action.terminal.new";
				key = "ctrl+shift+[Semicolon]";
			}
		];
		extensions = with pkgs.vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
			mads-hartmann.bash-ide-vscode
			timonwong.shellcheck
			jeff-hykin.better-shellscript-syntax
			jeff-hykin.better-nix-syntax
			jeff-hykin.better-jsonc-syntax
			jeff-hykin.better-dockerfile-syntax
			aaron-bond.better-comments
			naumovs.color-highlight
			mcu-debug.debug-tracker-vscode
			ms-vscode-remote.remote-containers
			mkhl.direnv
			ms-azuretools.vscode-docker
			p1c2u.docker-compose
			mikestead.dotenv
			editorconfig.editorconfig
			usernamehw.errorlens
			github.copilot
			bierner.markdown-preview-github-styles
			bierner.markdown-mermaid
			github.remotehub
			eamodio.gitlens
			kisstkondoros.vscode-gutter-preview
			visualstudioexptteam.vscodeintellicode
			visualstudioexptteam.intellicode-api-usage-examples
			yzhang.markdown-all-in-one
			davidanson.vscode-markdownlint
			pkief.material-icon-theme
			arrterian.nix-env-selector
			jnoortheen.nix-ide
			carlocardella.vscode-filesystemtoolbox
			zhuangtongfa.material-theme
			ms-vscode-remote.remote-ssh
			ms-vscode-remote.remote-ssh-edit
			semanticdiff.semanticdiff
			sidp.strict-whitespace
			albert.tabout
			actboy168.tasks
			ms-vscode.test-adapter-converter
			hbenl.vscode-test-explorer
			gruntfuggly.todo-tree
			panicbit.cargo
			vadimcn.vscode-lldb
			marus25.cortex-debug
			serayuzgur.crates
			tamasfe.even-better-toml
			github.vscode-github-actions
			github.copilot-chat
			github.vscode-pull-request-github
			mcu-debug.memory-view
			dustypomerleau.rust-syntax
			swellaby.vscode-rust-test-adapter
			rust-lang.rust-analyzer
			belfz.search-crates-io
			mtxr.sqltools
			vscodevim.vim
		];
	};

	home.packages = with pkgs; [
		# Language tools
		shellcheck
		nodePackages.bash-language-server
	];
}
