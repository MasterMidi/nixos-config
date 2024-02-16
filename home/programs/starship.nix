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
{theme, ...}:
with theme.withHashtag; let
  dark-text = base00;
  light-text = base07;
  error = base08;
  succes = base0B;

  shell = base0D;
  pc-info = base07;
  path = base04;
  git-module = base03;
  package-module = base0C;
  code-module = base0A;
in {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      add_newline = true;

      format = "($shlvl$nix_shell[](fg:${shell} bg:${pc-info}))$os$username$hostname$localip[](fg:${pc-info} bg:${path})$directory[](fg:${path} bg:${git-module})$git_branch$git_commit$git_state$git_status[](fg:${git-module} bg:${package-module})$package[](fg:${package-module} bg:${code-module})$container$kubernetes$docker_context$nodejs$rust$golang$php[](fg:${code-module})$cmd_duration\n$character";

      shlvl = {
        disabled = false;
        format = "[$symbol$shlvl]($style)";
        symbol = "󰜮";
        style = "${shell}";
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
          Ubuntu = "";
          Raspbian = "";
          NixOS = "";
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

      localip = {
        format = "@[$localipv4]($style) ";
        style = "bright-green bold";
        disabled = false;
        ssh_only = true;
      };

      hostname = {
        ssh_only = false;
        format = "[@[$hostname]($style)[$ssh_symbol]($style) ]($style)";
        style = "italic bg:${pc-info} fg:${dark-text}";
        ssh_symbol = " 󰌘"; #\uf817
        disabled = false;
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
        style = "fg:${light-text} bg:${path}";
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
        format = "[[ $symbol ($version) ](fg:${light-text} bg:${code-module})]($style)";
      };

      rust = {
        symbol = "";
        style = "fg:${dark-text} bg:${code-module} bold italic";
        format = "[ $symbol ($version )]($style)";
      };

      c = {
        symbol = "";
        style = "bg:${code-module}";
        format = "[[ $symbol ($toolchain::$version) ](fg:${light-text} bg:${code-module})]($style)";
      };

      golang = {
        symbol = "󰟓";
        style = "bg:${code-module}";
        format = "[[ $symbol ($version) ](fg:${light-text} bg:${code-module})]($style)";
      };

      php = {
        format = "[[ $symbol ($version) ](fg:${light-text} bg:${code-module})]($style)";
        symbol = "";
        style = "bg:${code-module}";
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
