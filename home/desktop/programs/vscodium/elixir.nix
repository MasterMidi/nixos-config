{inputs, ...}: {
  programs.vscode = {
    extensions = with inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
      jakebecker.elixir-ls
      phoenixframework.phoenix
    ];
  };
}
