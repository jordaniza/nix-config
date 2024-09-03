{
  "typescript.preferGoToSourceDefinition" = true;
  "explorer.confirmDragAndDrop" = false;
  "explorer.confirmDelete" = false;
  "peacock.affectStatusAndTitleBorders" = true;
  "peacock.affectActivityBar" = false;
  "peacock.affectSideBarBorder" = true;
  "peacock.affectEditorGroupBorder" = true;
  "peacock.affectTitleBar" = false;
  "peacock.affectSashHover" = false;
  "peacock.affectPanelBorder" = true;
  "editor.minimap.enabled" = false;
  "editor.renderWhitespace" = "none";
  "editor.renderControlCharacters" = false;
  "solidity.compileUsingRemoteVersion" = "latest";
  "[typescript].editor.defaultFormatter" = "esbenp.prettier-vscode";
  "[json].editor.defaultFormatter" = "esbenp.prettier-vscode";
  "svelte.enable-ts-plugin" = true;
  "svelte.plugin.svelte.note-new-transformation" = false;
  "liveServer.settings.donotShowInfoMsg" = true;
  "editor.formatOnSave" = true;
  "workbench.editorAssociations" = {"*.wasm" = "default";};
  "editor.inlineSuggest.enabled" = true;
  # "editor.fontFamily" = "'Fira Code' Consolas 'Courier New' monospace";
  "editor.fontLigatures" = true;
  "github.copilot.enable" = {
    "*" = true;
    "plaintext" = true;
    "markdown" = true;
    "scminput" = false;
    "yaml" = false;
    "solidity" = true;
  };
  "[python].editor.formatOnType" = true;
  "editor.tabSize" = 2;
  "editor.stickyTabStops" = true;
  "editor.detectIndentation" = false;
  "prettier.printWidth" = 120;
  "[dockerfile].editor.defaultFormatter" = "ms-azuretools.vscode-docker";
  "[jsonc].editor.defaultFormatter" = "esbenp.prettier-vscode";
  "typescript.updateImportsOnFileMove.enabled" = "always";
  "[javascript].editor.defaultFormatter" = "esbenp.prettier-vscode";
  "vim.insertModeKeyBindings" = [
    {
      before = ["g" "f"];
      after = ["<Esc>"];
    }
    {
      before = ["<C-h>"];
      after = [];
      commands = [
        {
          command = "cursorMove";
          args = {
            to = "left";
            by = "character";
            value = 1;
            select = false;
          };
        }
      ];
    }
    {
      before = ["<C-j>"];
      after = [];
      commands = [
        {
          command = "cursorMove";
          args = {
            to = "down";
            by = "line";
            value = 1;
            select = false;
          };
        }
      ];
    }
    {
      before = ["<C-k>"];
      after = [];
      commands = [
        {
          command = "cursorMove";
          args = {
            to = "up";
            by = "line";
            value = 1;
            select = false;
          };
        }
      ];
    }
    {
      before = ["<C-l>"];
      after = [];
      commands = [
        {
          command = "cursorMove";
          args = {
            to = "right";
            by = "character";
            value = 1;
            select = false;
          };
        }
      ];
    }
  ];
  "vim.normalModeKeyBindingsNonRecursive" = [
    {
      before = ["<leader>" "f" "f"];
      commands = ["workbench.action.quickOpen"];
    }
    {
      before = ["<leader>" "r" "n"];
      commands = ["editor.action.rename"];
    }
    {
      before = ["<leader>" "f" "w"];
      commands = ["workbench.view.search"];
    }
    {
      before = ["<leader>" "f" "s"];
      commands = ["search.action.focusSearchList"];
    }
    {
      before = ["<leader>" "e"];
      commands = ["workbench.view.explorer"];
    }
    {
      before = ["<leader>" "i"];
      commands = ["editor.action.showHover"];
    }
  ];
  "vim.whichwrap" = "h l";
  "vim.useSystemClipboard" = true;
  "editor.lineNumbers" = "relative";
  "vim.leader" = "<Space>";
  "solidity.telemetry" = true;
  "glassit-linux.opacity" = 90;
  "window.menuBarVisibility" = "hidden";
  "multiCommand.commands" = [
    {
      command = "multiCommand.openSidebarAndFocus";
      sequence = ["workbench.action.toggleSidebarVisibility" "workbench.action.focusSideBar"];
    }
  ];
  "glassit.alpha" = 245;
  "glassit.step" = 10;
}
