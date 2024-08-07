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
  
  {
    mode = "n";
    key = "<C-l>";
    action = "<cmd>lua if require'nvim-tree.view'.is_visible() then vim.cmd('wincmd l') end<CR>";
    options = {
      silent = true;
      desc = "Move to buffer from NvimTree";
    };
  }

  {
    mode = "n";
    key = "<C-h>";
    action = "<cmd>lua if require'nvim-tree.view'.is_visible() then vim.cmd('wincmd h') end<CR>";
    options = {
      silent = true;
      desc = "Move to NvimTree from buffer";
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
]
