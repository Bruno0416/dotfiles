-- ===========================================
--  NEOVIM PRO HYBRID (Estilo JDHao + Pywal)
-- ===========================================

-- 1. Opciones Básicas (Settings)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Visuales y Comportamiento
vim.opt.number = true         
vim.opt.relativenumber = false -- Números normales (1, 2, 3...)
vim.opt.mouse = "a"           
vim.opt.clipboard = "unnamedplus" 
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.cursorline = true     
vim.opt.scrolloff = 8

-- Indentación y Tabulaciones
vim.opt.expandtab = true      -- Convertir tabs a espacios
vim.opt.shiftwidth = 4        -- Tamaño de indentación
vim.opt.tabstop = 4
vim.opt.smartindent = true

-- Ventanas
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

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

  -- >> SISTEMA VISUAL BASE (PYWAL) <<
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

  -- >> PESTAÑAS SUPERIORES (BUFFERLINE - Estilo jdhao) <<
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers",
                separator_style = "slant", -- Estilo inclinado moderno
                always_show_bufferline = true,
                show_buffer_close_icons = false,
                show_close_icon = false,
                diagnostics = "nvim_lsp",
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "Explorador",
                        highlight = "Directory",
                        separator = true
                    }
                },
            },
            highlights = {
                fill = { bg = "NONE" }, -- Transparencia para pywal
                background = { bg = "NONE" },
            }
        })
    end
  },

  -- >> INTERFAZ FLOTANTE (NOICE) <<
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = false, 
        command_palette = true, 
        long_message_to_split = true,
        inc_rename = true, 
        lsp_doc_border = true, 
      },
      views = {
        cmdline_popup = { position = { row = "40%", col = "50%" }, size = { width = 60, height = "auto" } },
        popupmenu = { border = { style = "rounded", padding = { 0, 1 } } },
      },
    }
  },

  -- >> MENUS MEJORADOS <<
  { "stevearc/dressing.nvim", event = "VeryLazy" },

  -- >> BARRA DE ESTADO (LUALINE) <<
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "pywal",
          component_separators = '|',
          section_separators = { left = '', right = '' },
          globalstatus = true, -- Una sola barra para todas las ventanas (estilo moderno)
        },
        sections = {
          lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
          lualine_b = { 'filename', 'branch' },
          lualine_c = { 'diagnostics' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
        },
      })
    end,
  },

  -- >> EXPLORADOR DE ARCHIVOS <<
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true, indent_markers = { enable = true } },
        filters = { dotfiles = false },
        actions = { open_file = { quit_on_open = true } }, -- Cierra el arbol al abrir archivo
      })
    end,
  },

  -- >> GIT INTEGRATION (GITSIGNS) <<
  {
    "lewis6991/gitsigns.nvim",
    config = function()
        require('gitsigns').setup({
            current_line_blame = true, -- Muestra quién editó la línea actual
        })
    end
  },

  -- >> GUIAS DE INDENTACION <<
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
        indent = { char = "│" },
        scope = { enabled = false }, -- Desactiva scope si molesta con pywal
    },
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
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
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
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "rust", "bash", "json", "toml", "yaml" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  
  -- >> CONTEXTO FLOTANTE (Sticky Headers) <<
  {
      "nvim-treesitter/nvim-treesitter-context",
      opts = { mode = "cursor", max_lines = 3 },
  },

  -- >> AUTOCOMPLETADO <<
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      "rafamadriz/friendly-snippets", -- Snippets pre-hechos
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      require("luasnip.loaders.from_vscode").lazy_load()
      
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
        formatting = {
            format = lspkind.cmp_format({
                mode = 'symbol_text',
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
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      })
    end,
  },

  -- >> DASHBOARD <<
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        "   OMARCHY   ",
        "  PRO SETUP  ",
      }
      dashboard.section.buttons.val = {
        dashboard.button("e", "  Nuevo Archivo", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "  Buscar Archivo", ":Telescope find_files <CR>"),
        dashboard.button("r", "  Recientes", ":Telescope oldfiles <CR>"),
        dashboard.button("q", "  Salir", ":qa<CR>"),
      }
      require("alpha").setup(dashboard.config)
    end,
  },

  { "folke/which-key.nvim", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },

  -- >> LENGUAJES (LSP) <<
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "pyright", "lua_ls", "bashls", "rust_analyzer" } }
  },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig", config = function()
       local lspconfig = require('lspconfig')
       local capabilities = require('cmp_nvim_lsp').default_capabilities()
       -- Setup automatico para servidores instalados por mason
       require("mason-lspconfig").setup_handlers {
           function (server_name)
               lspconfig[server_name].setup {
                   capabilities = capabilities
               }
           end,
       }
  end},

})

-- 4. Keymaps (Atajos)
local keymap = vim.keymap.set

-- Archivos y Pestañas
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Arbol de Archivos" })
keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", { desc = "Siguiente Pestaña" })
keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "Anterior Pestaña" })
keymap("n", "<leader>x", ":bdelete<CR>", { desc = "Cerrar Pestaña Actual" })

-- Buscador
keymap("n", "<leader>ff", require('telescope.builtin').find_files, { desc = "Buscar Archivos" })
keymap("n", "<leader>fg", require('telescope.builtin').live_grep, { desc = "Buscar Texto" })
keymap("n", "<leader>fb", require('telescope.builtin').buffers, { desc = "Buscar en Abiertos" })

-- Ventanas
keymap("n", "<C-h>", "<C-w>h", { desc = "Izquierda" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Derecha" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Abajo" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Arriba" })

-- Utilidades
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<leader>w", ":w<CR>", { desc = "Guardar" })