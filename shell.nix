{
  pkgs,
  inputs,
  ...
}:
pkgs.devshell.mkShell {
  name = "nixos-config";
  packages = with pkgs; [
    nixpkgs-fmt
    nerdfix # fix nerdfont symbols in text files
    nurl
    nix-prefetch # prefetch urls to get hash
    nix-tree # visualize nix store
    nix-output-monitor # monitor nix build output
    nix-index # prebuilt-index nix store
    # nix-melt # view flake.lock files
    nix-init # quick start to packaging projects
    statix # find anti-patterns in nix code
    nix-du # disk usage of nix store
    nixos-generators
    nix-inspect

    # secret management
    sops
    ssh-to-age

    flake-checker # healthcheck for flake.lock files
    deploy-rs # deploy nixos to remote servers
  ];

  commands = with pkgs; [
    # {
    #   name = git.pname;
    #   help = git.meta.description;
    #   category = "vcs";
    #   package = git;
    # }
    {
      name = "nix-update";
      category = "nixos";
      help = "good luck";
      command = "${./scripts/update.sh}";
    }

    {
      name = "dply";
      category = "deploy";
      help = "deploy to remote server";
      command = "nix run . -- $1";
    }

    {
      name = "evl";
      category = "nixos";
      help = "evaluate nixos configuration";
      command = "nix eval --impure .#nixosConfigurations.$1";
    }

    {
      name = "usops";
      category = "secrets";
      help = "updates all sops secrets with the current keys in .sops.yaml";
      command = "${./scripts/update-sops-keys.sh}";
    }
  ];
}
