{
  # Programming Languages
  "typescript.preferGoToSourceDefinition" = true;
  "[typescript].editor.defaultFormatter" = "esbenp.prettier-vscode";
  "typescript.updateImportsOnFileMove.enabled" = "always";
  "[javascript].editor.defaultFormatter" = "esbenp.prettier-vscode";
  "[json].editor.defaultFormatter" = "esbenp.prettier-vscode";
  "[solidity].formatter" = "prettier";
  "[solidity]" = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };

  # Editor
  "workbench.colorTheme" = "Dracula Theme";
  "explorer.confirmDragAndDrop" = false;
  "explorer.confirmDelete" = false;
  "editor.minimap.enabled" = false;
  "editor.renderWhitespace" = "none";
  "editor.renderControlCharacters" = false;
  "editor.fontLigatures" = true;
  "editor.formatOnSave" = true;
  "editor.inlineSuggest.enabled" = true;
  "editor.tabSize" = 2;
  "editor.stickyTabStops" = true;
  "editor.detectIndentation" = false;
  "editor.lineNumbers" = "relative";
  # "editor.fontFamily" = "'Fira Code' Consolas 'Courier New' monospace";

  "window.menuBarVisibility" = "hidden";
  "window.titleBarStyle" = "custom";
  "window.customMenuBarAltFocus" = false;
  "window.enableMenuBarMnemonics" = false;

  ## Peacock
  "peacock.affectActivityBar" = false;
  "peacock.affectSideBarBorder" = true;
  "peacock.affectEditorGroupBorder" = true;
  "peacock.affectTitleBar" = false;
  "peacock.affectSashHover" = false;
  "peacock.affectPanelBorder" = true;
  "peacock.affectStatusAndTitleBorders" = true;

  ## Github
  "github.copilot.enable" = {
    "*" = true;
    "plaintext" = true;
    "markdown" = false;
    "scminput" = false;
    "yaml" = false;
    "solidity" = true;
  };

  ## Prettier
  "prettier.printWidth" = 120;

  ## Vim
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
  "vim.leader" = "<Space>";

  # MultiCommand
  "multiCommand.commands" = [
    {
      command = "multiCommand.openSidebarAndFocus";
      sequence = ["workbench.action.toggleSidebarVisibility" "workbench.action.focusSideBar"];
    }
  ];

  # GlassIt
  "glassit.alpha" = 245;
  "glassit.step" = 10;
}
