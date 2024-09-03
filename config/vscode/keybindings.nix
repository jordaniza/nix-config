[
  {
    key = "alt+-";
    command = "-decreaseSearchEditorContextLines";
    when = "inSearchEditor";
  }
  {
    key = "alt+left";
    command = "workbench.action.navigateBack";
  }
  {
    key = "alt+=";
    command = "-increaseSearchEditorContextLines";
    when = "inSearchEditor";
  }
  {
    key = "alt+=";
    command = "workbench.action.navigateForwardInEditLocations";
  }
  {
    key = "alt+right";
    command = "-workbench.action.terminal.focusNextPane";
    when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
  }
  {
    key = "alt+right";
    command = "-gitlens.key.alt+right";
    when = "gitlens:key:alt+right";
  }
  {
    key = "ctrl+shift+-";
    command = "-workbench.action.navigateForward";
    when = "canNavigateForward";
  }
  {
    key = "alt+left";
    command = "-gitlens.key.alt+left";
    when = "gitlens:key:alt+left";
  }
  {
    key = "alt+left";
    command = "-workbench.action.terminal.focusPreviousPane";
    when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
  }
  {
    key = "tab";
    command = "tab";
    when = "editorTextFocus && !editorReadonly && !editorTabMovesFocus";
  }
  {
    key = "shift+tab";
    command = "outdent";
    when = "editorTextFocus && !editorReadonly && !editorTabMovesFocus";
  }
  {
    key = "tab";
    command = "editor.action.inlineSuggest.commit";
    when = "github.copilot.activated && inlineSuggestionVisible";
  }
  {
    key = "shift+tab";
    command = "editor.action.inlineSuggest.hide";
    when = "github.copilot.activated && inlineSuggestionVisible";
  }
  {
    key = "ctrl+enter";
    command = "github.copilot.generate";
    when = "editorTextFocus && github.copilot.activated && !inInteractiveInput && !interactiveEditorFocused";
  }
  {
    key = "ctrl+/";
    command = "-github.copilot.generate";
    when = "editorTextFocus && github.copilot.activated && !inInteractiveInput && !interactiveEditorFocused";
  }
  {
    key = "ctrl+x";
    command = "workbench.action.closeActiveEditor";
  }
  {
    key = "tab";
    command = "selectNextSuggestion";
    when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
  }
  {
    key = "alt+e";
    command = "workbench.files.action.focusFilesExplorer";
  }
  {
    key = "ctrl+j";
    command = "workbench.action.terminal.focusPrevious";
    when = "terminalFocus && terminalHasBeenCreated && !terminalEditorFocus || terminalFocus && terminalProcessSupported && !terminalEditorFocus";
  }
  {
    key = "ctrl+pageup";
    command = "-workbench.action.terminal.focusPrevious";
    when = "terminalFocus && terminalHasBeenCreated && !terminalEditorFocus || terminalFocus && terminalProcessSupported && !terminalEditorFocus";
  }
  {
    key = "ctrl+k";
    command = "workbench.action.terminal.focusNext";
    when = "terminalFocus && terminalHasBeenCreated && !terminalEditorFocus || terminalFocus && terminalProcessSupported && !terminalEditorFocus";
  }
  {
    key = "ctrl+shift+h";
    command = "workbench.action.focusPreviousGroup";
  }
  {
    key = "ctrl+`";
    command = "workbench.action.focusActiveEditorGroup";
    when = "terminalFocus";
  }
  {
    key = "ctrl+alt+l";
    command = "workbench.action.nextEditor";
  }
  {
    key = "ctrl+alt+h";
    command = "workbench.action.previousEditor";
  }
  {
    key = "ctrl+j";
    command = "workbench.action.navigateDown";
    when = "editorTextFocus && vim.active && vim.mode == 'Normal'";
  }
  {
    key = "ctrl+h";
    command = "workbench.action.navigateLeft";
    when = "editorTextFocus && vim.active && vim.mode == 'Normal'";
  }
  {
    key = "ctrl+l";
    command = "workbench.action.navigateRight";
    when = "editorTextFocus && vim.active && vim.mode == 'Normal' || searchViewletVisible || filesExplorerFocus || activeViewlet == 'workbench.view.extensions'";
  }
  {
    key = "ctrl+k";
    command = "workbench.action.navigateUp";
    when = "editorTextFocus && vim.active && vim.mode == 'Normal'";
  }
  {
    key = "alt+v";
    command = "workbench.action.terminal.toggleTerminal";
  }
  {
    key = "alt+s";
    command = "workbench.action.terminal.split";
    when = "terminalFocus";
  }
  {
    key = "ctrl+k";
    command = "workbench.action.focusActiveEditorGroup";
    when = "terminalFocus";
  }
  {
    key = "ctrl+h";
    command = "workbench.action.focusActiveEditorGroup";
    when = "terminalFocus";
  }
  {
    key = "ctrl+shift+x";
    command = "workbench.view.extensions";
  }
  {
    key = "ctrl+alt+t";
    command = "multiCommand.toggleTerminalOrientation";
  }
  {
    key = "alt+x";
    command = "workbench.action.terminal.kill";
    when = "terminalFocus";
  }
  {
    key = "ctrl+n";
    command = "extension.multiCommand.execute";
    args = {command = "multiCommand.openSidebarAndFocus";};
    when = "!sideBarVisible && !suggestWidgetVisible";
  }
  {
    key = "ctrl+n";
    command = "workbench.action.toggleSidebarVisibility";
    when = "sideBarVisible && !suggestWidgetVisible";
  }
  {
    key = "ctrl+n";
    command = "workbench.action.quickOpenNavigateNext";
    when = "inQuickOpen && inFilesPicker";
  }
  {
    key = "ctrl+p";
    command = "workbench.action.quickOpenNavigatePrevious";
    when = "inQuickOpen && inFilesPicker";
  }
  {
    key = "a";
    command = "explorer.newFile";
    when = "explorerViewletFocus && !inputFocus";
  }
  {
    key = "c";
    command = "filesExplorer.copy";
    when = "explorerViewletFocus && !inputFocus";
  }
  {
    key = "p";
    command = "filesExplorer.paste";
    when = "explorerViewletFocus && !inputFocus";
  }
]
