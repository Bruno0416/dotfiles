-- ===========================================
--  NEOVIM ULTIMATE PYWAL (Estilo Omarchy)
-- ===========================================

-- 1. Opciones Básicas (Settings)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true         -- Mostrar números de línea
vim.opt.relativenumber = false -- [CAMBIO] Desactivado para que no se vean "al revés"
vim.opt.mouse = "a"           
vim.opt.clipboard = "unnamedplus" 
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = "split"
vim.opt.cursorline = true     
vim.opt.scrolloff = 10        
vim.opt.termguicolors = true  

-- 2. Bootstrap de Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Lista de Plugins
require("lazy").setup({

  -- >> TEMA Y COLORES (PYWAL) <<
  {
    "AlphaTechnolog/pywal.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local pywal = require("pywal")
      pywal.setup()
      vim.cmd("colorscheme pywal")
    end,
  },

  -- >> INTERFAZ FLOTANTE Y NOTIFICACIONES (NOICE) <<
  -- *Esto crea la 'mini consola' flotante al presionar : *
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = false, -- Si es false, la búsqueda (/) también flota en el centro
        command_palette = true, -- Mueve la línea de comandos (:) al centro
        long_message_to_split = true,
        inc_rename = false, 
        lsp_doc_border = true, -- Bordes bonitos en la documentación
      },
      views = {
        cmdline_popup = {
            position = {
                row = "40%",
                col = "50%",
            },
            size = {
                width = 60,
                height = "auto",
            },
        },
        popupmenu = {
            relative = "editor",
            position = {
                row = 8,
                col = "50%",
            },
            size = {
                width = 60,
                height = 10,
            },
            border = {
                style = "rounded",
                padding = { 0, 1 },
            },
            win_options = {
                winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
            },
        },
      },
    }
  },

  -- >> MENUS MEJORADOS (DRESSING) <<
  { "stevearc/dressing.nvim", event = "VeryLazy" },

  -- >> BARRA DE ESTADO (LUALINE) <<
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "pywal",
          component_separators = { left = '|', right = '|'},
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
          lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
        },
      })
    end,
  },

  -- >> EXPLORADOR DE ARCHIVOS (NVIM-TREE) <<
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { 
            group_empty = true,
            indent_markers = { enable = true }, -- Lineas guias en el arbol
        },
        filters = { dotfiles = false },
      })
    end,
  },

  -- >> BUSCADOR (TELESCOPE) <<
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git" },
          mappings = {
            i = { ["<C-u>"] = false, ["<C-d>"] = false },
          },
        },
      })
    end,
  },

  -- >> RESALTADO (TREESITTER) <<
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "rust", "bash", "json" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- >> AUTOCOMPLETADO CON ICONOS (CMP + LSPKIND) <<
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim", -- Añade iconos al menu
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
        formatting = {
            format = lspkind.cmp_format({
                mode = 'symbol_text', -- muestra icono y texto
                maxwidth = 50,
                ellipsis_char = '...',
            })
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      })
    end,
  },

  -- >> MENU DE INICIO (DASHBOARD) <<
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        "   __          _                 ",
        "  / _| ___  __| | ___  _ __ __ _ ",
        " | |_ / _ \\/ _` |/ _ \\| '__/ _` |",
        " |  _|  __/ (_| | (_) | | | (_| |",
        " |_|  \\___|\\__,_|\\___/|_|  \\__,_|",
        "                                 ",
      }
      require("alpha").setup(dashboard.config)
    end,
  },

  { "folke/which-key.nvim", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- >> LENGUAJES (LSP) <<
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "pyright", "lua_ls", "bashls" } }
  },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig", config = function()
       local lspconfig = require('lspconfig')
       -- Configura aquí tus lenguajes si hace falta
  end},

})

-- 4. Keymaps
local keymap = vim.keymap.set
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Explorador de Archivos" })
keymap("n", "<leader>ff", require('telescope.builtin').find_files, { desc = "[F]ind [F]iles" })
keymap("n", "<leader>fg", require('telescope.builtin').live_grep, { desc = "[F]ind [G]rep" })
keymap("n", "<leader>fb", require('telescope.builtin').buffers, { desc = "[F]ind [B]uffers" })
keymap("n", "<C-h>", "<C-w>h", { desc = "Izquierda" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Derecha" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Abajo" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Arriba" })
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")