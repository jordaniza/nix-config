[
  # general
  {
    mode = "i";
    key = "gf";
    action = "<Esc>";
    options = {
      noremap = true;
      silent = true;
      desc = "Go from insert to normal mode";
    };
  }

  {
    mode = "n";
    key = "<C-l>";
    action = "<C-w>l";
    options = {
      noremap = true;
      silent = true;
      desc = "Move to right split";
    };
  }

  {
    mode = "n";
    key = "<C-h>";
    action = "<C-w>h";
    options = {
      noremap = true;
      silent = true;
      desc = "Move to left split";
    };
  }
  #
  # clear highlight with leader /
  {
    mode = "n";
    key = "<leader>/";
    action = ":nohlsearch<CR>";
    options = {
      noremap = true;
      silent = true;
      desc = "Clear search highlight";
    };
  }

  # code editing

  {
    mode = "n";
    key = "<leader>i";
    action = "<cmd>lua vim.diagnostic.open_float()<CR>";
    options = {
      desc = "Highlight diagnostic";
      noremap = true;
      silent = true;
    };
  }

  # tree
  {
    mode = "n";
    key = "<C-n>";
    action = ":NvimTreeToggle<CR>";
    options = {
      silent = true;
      desc = "Toggle NvimTree";
    };
  }

  # telescope
  {
    mode = "n";
    key = "<leader>ff";
    action = "<cmd>lua require('telescope.builtin').find_files()<CR>";
    options = {
      silent = true;
      desc = "Find files with Telescope";
    };
  }

  {
    mode = "n";
    key = "<leader>fw";
    action = "<cmd>lua require('telescope.builtin').live_grep()<CR>";
    options = {
      silent = true;
      desc = "Live grep with Telescope";
    };
  }

  # harpoon
  {
    mode = "n";
    key = "<leader>ha";
    action = "<cmd>lua require('harpoon.mark').add_file()<CR>";
    options = {
      silent = true;
      desc = "Add file to Harpoon";
    };
  }

  {
    mode = "n";
    key = "<leader>hl";
    action = "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>";
    options = {
      silent = true;
      desc = "Toggle Harpoon List";
    };
  }

  {
    mode = "n";
    key = "<leader>1";
    action = "<cmd>lua require('harpoon.ui').nav_file(1)<CR>";
    options = {
      silent = true;
      desc = "Navigate to Harpoon file 1";
    };
  }

  {
    mode = "n";
    key = "<leader>2";
    action = "<cmd>lua require('harpoon.ui').nav_file(2)<CR>";
    options = {
      silent = true;
      desc = "Navigate to Harpoon file 2";
    };
  }

  {
    mode = "n";
    key = "<leader>3";
    action = "<cmd>lua require('harpoon.ui').nav_file(3)<CR>";
    options = {
      silent = true;
      desc = "Navigate to Harpoon file 3";
    };
  }

  {
    mode = "n";
    key = "<leader>4";
    action = "<cmd>lua require('harpoon.ui').nav_file(4)<CR>";
    options = {
      silent = true;
      desc = "Navigate to Harpoon file 4";
    };
  }

  {
    mode = "n";
    key = "<leader>5";
    action = "<cmd>lua require('harpoon.ui').nav_file(5)<CR>";
    options = {
      silent = true;
      desc = "Navigate to Harpoon file 5";
    };
  }
  {
    mode = "n";
    key = "<leader>6";
    action = "<cmd>lua require('harpoon.ui').nav_file(6)<CR>";
    options = {
      silent = true;
      desc = "Navigate to Harpoon file 6";
    };
  }
  {
    mode = "n";
    key = "<leader>7";
    action = "<cmd>lua require('harpoon.ui').nav_file(7)<CR>";
    options = {
      silent = true;
      desc = "Navigate to Harpoon file 7";
    };
  }
  {
    mode = "n";
    key = "<leader>8";
    action = "<cmd>lua require('harpoon.ui').nav_file(8)<CR>";
    options = {
      silent = true;
      desc = "Navigate to Harpoon file 8";
    };
  }
  {
    mode = "n";
    key = "<leader>9";
    action = "<cmd>lua require('harpoon.ui').nav_file(9)<CR>";
    options = {
      silent = true;
      desc = "Navigate to Harpoon file 9";
    };
  }

  # buffer navigation
  {
    mode = "n";
    key = "<A-l>";
    action = ":BufferLineCycleNext<CR>";
    options = {
      noremap = true;
      silent = true;
      desc = "Go to next buffer";
    };
  }

  {
    mode = "n";
    key = "<A-h>";
    action = ":BufferLineCyclePrev<CR>";
    options = {
      noremap = true;
      silent = true;
      desc = "Go to previous buffer";
    };
  }

  {
    mode = "n";
    key = "<C-x>";
    action = ":bp\|bd #<CR>";
    options = {
      noremap = true;
      silent = true;
      desc = "Close current buffer";
    };
  }

  # ctrl s save
  {
    mode = "n";
    key = "<C-s>";
    action = ":w<CR>";
    options = {
      noremap = true;
      silent = true;
      desc = "Save file";
    };
  }

  {
    mode = "i";
    key = "<C-s>";
    action = "<Esc>:w<CR>a";
    options = {
      noremap = true;
      silent = true;
      desc = "Save file";
    };
  }

  {
    mode = "v";
    key = "<C-s>";
    action = "<Esc>:w<CR>";
    options = {
      noremap = true;
      silent = true;
      desc = "Save file";
    };
  }

  # enable copilot with leader ce and disable with leader cd
  {
    mode = "n";
    key = "<leader>ce";
    action = "<cmd>Copilot enable<CR>";
    options = {
      noremap = true;
      silent = true;
      desc = "Enable Copilot";
    };
  }

  {
    mode = "n";
    key = "<leader>cd";
    action = "<cmd>Copilot disable<CR>";
    options = {
      noremap = true;
      silent = true;
      desc = "Disable Copilot";
    };
  }
]
