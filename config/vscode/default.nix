{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      vscodevim.vim
      github.copilot
      rust-lang.rust-analyzer
      dracula-theme.theme-dracula
      johnpapa.vscode-peacock
      mikestead.dotenv
      ms-vscode.live-server
      esbenp.prettier-vscode
    ];
    userSettings = import ./userSettings.nix;
    keybindings = import ./keybindings.nix;
  };
}
