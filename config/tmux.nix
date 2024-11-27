{
  config,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      {
        plugin = dracula;
        extraConfig = ''
                 set -g @dracula-show-battery true
                 set -g @dracula-show-powerline true
          set -g @dracula-show-weather false
          set -g @dracula-show-border-contrast true
        '';
      }
      yank
    ];
    extraConfig = ''
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle

      unbind '"'
      unbind %
      bind v split-window -h  -c "#{pane_current_path}"
      bind s split-window -v  -c "#{pane_current_path}"


      bind-key z resize-pane -Z

      unbind ]
      bind a copy-mode

      bind r command-prompt -I "#W" "rename-window '%%'"
    '';
  };
}
