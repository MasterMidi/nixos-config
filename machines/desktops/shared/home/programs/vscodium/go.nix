{inputs, ...}: {
  programs.vscode.profiles.default = {
    extensions = with inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
      golang.go
      mtxr.sqltools-driver-pg
    ];
  };
}
