{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
        aaron-bond.better-comments
        jeff-hykin.better-dockerfile-syntax
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
        zhuangtongfa.material-theme
        christian-kohler.path-intellisense
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
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      ];
    })
  ];
}
