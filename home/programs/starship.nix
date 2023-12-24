{...}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      add_newline = true;

      format = "([](fg:shell)$shell$nix_shell[](fg:shell bg:pc-info))$os$shlvl$username$hostname$localip[](fg:pc-info bg:path)$directory[](fg:path bg:git-module)$git_branch$git_commit$git_state$git_status[](fg:git-module bg:package-module)$package[](fg:package-module bg:code-module)$container$kubernetes$docker_context$nodejs$rust$golang$php[](fg:code-module)$cmd_duration\n$character";

      palette = "default";

      palettes.default = {
        dark-text = "#000000";
        light-text = "#e3e5e5";
        light-color-text = "#a3be8c";
        dark-color-text = "#2f3728";
        error-highlight = "#e06c75";
        succes-highlight = "#a3be8c";

        shell = "#F78E69";
        pc-info = "#e5e9f0";
        path = "#a3be8c";
        git-module = "#778b66";
        package-module = "#4b5740";
        code-module = "#1f241a";
      };

      shlvl = {
        disabled = false;
        format = "[$symbol$shlvl]($style)";
        symbol = "󰜮";
        style = "shell";
      };

      shell = {
        format = "[$indicator]($style)";
        disabled = false; # module not usefull for me
        style = "bold bg:shell fg:dark-text";
        powershell_indicator = " ";
        bash_indicator = "BASH"; #bash icon
        unknown_indicator = "# ";
      };

      nix_shell = {
        format = "[( $name::$state)]($style)";
        style = "bold italic bg:shell fg:dark-text";
        impure_msg = "impure";
        pure_msg = "pure";
        heuristic = true;
      };

      os = {
        format = "[ $symbol ]($style)";
        style = "fg:dark-text bg:pc-info";
        disabled = false;
        symbols = {
          Windows = "";
          Linux = "";
          Mint = "";
          Arch = "";
          Ubuntu = "";
          Raspbian = "";
          NixOS = "";
          Unknown = "❓";
        };
      };

      username = {
        format = "[ $user]($style)";
        style_user = "italic fg:dark-text bg:pc-info";
        style_root = "italic fg:error-highlight bg:pc-info";
        disabled = false;
        show_always = true;
      };

      localip = {
        format = "@[$localipv4]($style) ";
        style = "bright-green bold";
        disabled = false;
        ssh_only = true;
      };

      hostname = {
        ssh_only = false;
        format = "[@[$hostname]($style)[$ssh_symbol]($style) ]($style)";
        style = "italic bg:pc-info fg:dark-text";
        ssh_symbol = " 󰌘"; #\uf817
        disabled = false;
      };

      git_branch = {
        symbol = ""; # 
        style = "bg:git-module";
        format = "[[ $symbol $branch ](fg:light-text bg:git-module)]($style)";
        only_attached = true;
      };

      git_commit = {
        only_detached = true;
        format = "[󰜘$hash]($style) ";
        style = "bright-yellow bold";
      };

      git_state = {
        style = "bright-purple bold";
      };

      git_status = {
        style = "bg:git-module";
        format = "[[($all_status$ahead_behind )](fg:light-text bg:git-module)]($style)";
      };

      directory = {
        style = "fg:package-module bg:path";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        read_only = "󰌾";
        substitutions = {
          "Documents" = "󰈙";
          "Downloads" = "";
          "Music" = "";
          "Pictures" = "";
        };
      };

      cmd_duration = {
        min_time = 1;
        format = "[ $duration]($style) ";
        style = "bright-blue";
      };

      jobs = {
        style = "bright-green bold";
      };

      character = {
        success_symbol = "[❯](fg:succes-highlight)";
        error_symbol = "[✗](fg:error-highlight)";
      };

      container = {
        format = "[$symbol \[$name\] ]($style)";
        symbol = "⬢";
        style = "fg:light-color-text bg:code-module";
      };

      docker_context = {
        format = "[$symbol $context]($style)";
        symbol = "";
        style = "fg:light-color-text bg:code-module";
      };

      package = {
        format = "[ $symbol $version ]($style)";
        style = "fg:light-color-text bg:package-module";
        symbol = "󰏗";
        display_private = true;
      };

      nodejs = {
        symbol = "";
        style = "bg:code-module";
        format = "[[ $symbol ($version) ](fg:light-color-text bg:code-module)]($style)";
      };

      rust = {
        symbol = "";
        style = "fg:light-color-text bg:code-module";
        format = "[ $symbol ($version )]($style)";
      };

      c = {
        symbol = "";
        style = "bg:code-module";
        format = "[[ $symbol ($toolchain::$version) ](fg:light-color-text bg:code-module)]($style)";
      };

      golang = {
        symbol = "󰟓";
        style = "bg:code-module";
        format = "[[ $symbol ($version) ](fg:light-color-text bg:code-module)]($style)";
      };

      php = {
        format = "[[ $symbol ($version) ](fg:light-color-text bg:code-module)]($style)";
        symbol = "";
        style = "bg:code-module";
      };

      kubernetes = {
        format = "[$symbol ($user on )($cluster in )$context \($namespace\) ]($style)";
        symbol = " 󰠳";
        detect_files = ["k8s"];
        style = "fg:light-color-text bg:code-module";
        disabled = false;
        context_aliases = {
          "dev.local.cluster.k8s" = "dev";
          ".*/openshift-cluster/.*" = "openshift";
          "gke_.*_(?P<var_cluster>[\\w-]+)" = "gke-$var_cluster";
        };
        user_aliases = {
          "dev.local.cluster.k8s" = "dev";
          "kind-.*" = "kind";
          "root/.*" = "root";
        };
      };
    };
  };
}
