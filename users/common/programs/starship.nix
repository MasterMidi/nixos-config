# base00 = "#282828";
# base01 = "#3C3836";
# base02 = "#504945";
# base03 = "#665C54";
# base04 = "#BDAE93";
# base05 = "#D5C4A1";
# base06 = "#EBDBB2";
# base07 = "#FBF1C7";
# base08 = "#FB4934";
# base09 = "#FE8019";
# base0A = "#FABD2F";
# base0B = "#B8BB26";
# base0C = "#8EC07C";
# base0D = "#83A598";
# base0E = "#D3869B";
# base0F = "#D65D0E";
#9EB5D5
#1D2021
{config, ...}:
with config.colorScheme.palette; let
  dark-text = "#${base00}";
  light-text = "#${base07}";
  error = "#${base08}";
  succes = "#${base0B}";

  network = "#${base0E}";
  pc-info = "#${base07}";
  shell = "#${base0D}";
  path = "#${base04}";
  git-module = "#${base03}";
  package-module = "#${base0C}";
  code-module = "#${base0A}";

  section = elems: sep: fg: bg: "${builtins.concatStringsSep "" elems}[${sep}](fg:${fg} bg:${bg})";
  ifSection = elems: sep: fg: bg: "(${builtins.concatStringsSep "" elems}[${sep}](fg:${fg} bg:${bg}))";
in {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      add_newline = true;

      # format = "($nix_shell$shlvl[](fg:${shell} bg:${pc-info}))$os$username$hostname$localip$sudo[](fg:${pc-info} bg:${path})$directory[](fg:${path} bg:${git-module})$git_branch$git_commit$git_state$git_status[](fg:${git-module} bg:${package-module})$package[](fg:${package-module} bg:${code-module})$container$kubernetes$docker_context$nodejs$rust$golang$php[](fg:${code-module})$cmd_duration\n$character";
      format = builtins.concatStringsSep "" [
        (section ["$os" "$username" "$hostname" "$sudo"] "" pc-info network)
        (section ["\${custom.ssh_host_ip}"] "" network path)
        (section ["$directory"] "" path git-module)
        (section ["$git_branch" "$git_commit" "$git_state$" "git_status"] "" git-module shell)
        (ifSection ["$nix_shell" "$direnv" "$shlvl"] "" shell package-module)
        (section ["$package" "$container" "$kubernetes" "$docker_context"] "" package-module code-module)
        (section ["$lua" "$nodejs" "$rust" "$golang" "$php"] "" code-module "")
        "$cmd_duration\n$character"
      ];

      sudo = {
        format = "[$symbol]($style)";
        style = "fg:${dark-text} bg:${pc-info}";
        symbol = "󱑷 ";
        disabled = false;
      };

      direnv = {
        format = "[$symbol$loaded/$allowed ]($style)";
        style = "fg:${dark-text} bg:${shell}";
        symbol = "";
        allowed_msg = "󰄬";
        not_allowed_msg = "";
        denied_msg = "";
        loaded_msg = "";
        unloaded_msg = "";
        disabled = true;
      };

      shlvl = {
        disabled = false;
        format = "[$symbol$shlvl]($style)";
        symbol = "󰜮";
        style = "bg:${shell} fg:${dark-text}";
      };

      shell = {
        format = "[$indicator]($style)";
        disabled = false; # module not usefull for me
        style = "bold bg:${shell} fg:${dark-text}";
        powershell_indicator = " ";
        bash_indicator = " "; #bash icon
        unknown_indicator = "󱆃 ";
      };

      nix_shell = {
        format = "[( $name $state )]($style)";
        style = "bold italic bg:${shell} fg:${dark-text}";
        impure_msg = "󰂖";
        pure_msg = "󰜗";
        heuristic = true;
      };

      os = {
        format = "[ $symbol ]($style)";
        style = "fg:${dark-text} bg:${pc-info}";
        disabled = false;
        symbols = {
          Windows = "";
          Linux = "";
          Mint = "";
          Arch = "";
          Fedora = "";
          Raspbian = "";
          NixOS = "";
          openSUSE = "";
          SUSE = "";
          Ubuntu = "";
          EndeavourOS = "";
          Debian = "";
          Unknown = "❓";
        };
      };

      username = {
        format = "[ $user]($style)";
        style_user = "italic fg:${dark-text} bg:${pc-info}";
        style_root = "italic fg:${error} bg:${pc-info}";
        disabled = false;
        show_always = true;
      };

      hostname = {
        ssh_only = false;
        format = "[@[$hostname]($style)[$ssh_symbol]($style) ]($style)";
        style = "italic bg:${pc-info} fg:${dark-text}";
        ssh_symbol = " 󰌘"; #\uf817
        disabled = false;
      };

      localip = {
        format = "[ $localipv4]($style)";
        style = "italic fg:${dark-text} bg:${network}";
        disabled = false;
        ssh_only = true;
      };

      custom.ssh_host_ip = {
        description = "Shows IP and Interface when connected via SSH";
        command = ''
IP=$(echo $SSH_CONNECTION | awk '{print $3}')
IF=$(ip -o addr show to "$IP" | awk '{print $2}')
echo "$IP ($IF)"
'';
        when = "test -n \"$SSH_CONNECTION\"";
        format = "[ $output]($style)";
        #symbol = "󰌘 ";
        style = "italic fg:${dark-text} bg:${network}";
      };

      git_branch = {
        symbol = ""; # 
        style = "fg:${light-text} bg:${git-module} bold";
        format = "[ $symbol $branch ]($style)";
        only_attached = true;
      };

      git_commit = {
        only_detached = true;
        format = "[󰜘$hash]($style) ";
        style = "fg:${light-text} bg:${git-module} bold";
      };

      git_state = {
        style = "fg:${light-text} bg:${git-module} bold";
      };

      git_status = {
        style = "fg:${light-text} bg:${git-module}";
        format = "[($all_status$ahead_behind )]($style)";
      };

      directory = {
        style = "fg:${dark-text} bg:${path}";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "../";
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
        success_symbol = "[❯](fg:${succes})";
        error_symbol = "[✗](fg:${error})";
      };

      container = {
        format = "[$symbol \[$name\] ]($style)";
        symbol = "⬢";
        style = "fg:${light-text} bg:${code-module}";
      };

      docker_context = {
        format = "[$symbol $context]($style)";
        symbol = "";
        style = "fg:${light-text} bg:${code-module}";
      };

      package = {
        format = "[ $symbol $version ]($style)";
        style = "fg:${dark-text} bg:${package-module} bold";
        symbol = "󰏗";
        display_private = true;
      };

      nodejs = {
        symbol = "󰎙";
        style = "${dark-text} bg:${code-module}";
        format = "[[ $symbol ($version) ](fg:${dark-text} bg:${code-module})]($style)";
      };

      rust = {
        symbol = "";
        style = "fg:${dark-text} bg:${code-module} bold italic";
        format = "[ $symbol ($version )]($style)";
      };

      c = {
        symbol = "";
        style = "bg:${code-module}";
        format = "[[ $symbol ($toolchain::$version) ](fg:${dark-text} bg:${code-module})]($style)";
      };

      golang = {
        symbol = "󰟓";
        style = "bg:${code-module}";
        format = "[[ $symbol ($version) ](fg:${dark-text} bg:${code-module})]($style)";
      };

      php = {
        format = "[[ $symbol ($version) ](fg:${dark-text} bg:${code-module})]($style)";
        symbol = "";
        style = "bg:${code-module}";
      };

      lua = {
        format = "[ $symbol ($version) ]($style)";
        symbol = "󰢱";
        style = "fg:${dark-text} bg:${code-module}";
      };

      dotnet = {
        format = "[ $symbol ($version) ($tfm) ]($style)";
        symbol = "";
        style = "fg:${dark-text} bg:${code-module}";
      };

      python = {
        format = "[ $symbol$pyenv_prefix($version )(\($virtualenv\) )]($style)";
        symbol = "";
        style = "fg:${light-text} bg:${code-module}";
      };

      kubernetes = {
        format = "[ $symbol ($user on )($cluster in )$context \($namespace\) ]($style)";
        symbol = "󰠳 ";
        detect_files = ["k8s"];
        style = "fg:${light-text} bg:${code-module}";
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
