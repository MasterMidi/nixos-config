{inputs, ...}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./treesitter.nix
    ./lsp.nix
  ];

  programs.nixvim = {
    enable = true;
    colorschemes.gruvbox.enable = true;

    plugins.nvim-tree = {
      enable = true;
      openOnSetupFile = true;
      autoReloadOnWrite = true;
    };
  };
}
