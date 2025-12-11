-- ===========================================
--  NEOVIM OMARCHY CLONE (LazyVim Style)
-- ===========================================

-- 1. Opciones Básicas (Settings)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Comportamiento Visual
vim.opt.number = true         
vim.opt.relativenumber = false 
vim.opt.mouse = "a"           
vim.opt.clipboard = "unnamedplus" 
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.cursorline = true     
vim.opt.scrolloff = 8
vim.opt.wrap = false

-- Indentación
vim.opt.expandtab = true      
vim.opt.shiftwidth = 4        
vim.opt.tabstop = 4
vim.opt.smartindent = true

-- Ventanas y Paneles
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

-- 3. Plugins
require("lazy").setup({

  -- >> TEMA: PYWAL (Integrado con el sistema) <<
  {
    "AlphaTechnolog/pywal.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local pywal = require("pywal")
      pywal.setup()
      vim.cmd("colorscheme pywal")
      -- Forzar transparencia extra
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    end,
  },

  -- >> PESTAÑAS SUPERIORES (Bufferline) <<
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Pestaña Anterior" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Pestaña Siguiente" },
      { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Elegir Pestaña" },
      { "<leader>x", "<cmd>bdelete<cr>", desc = "Cerrar Buffer" },
    },
    opts = {
      options = {
        mode = "buffers",
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        offsets = {
            { filetype = "NvimTree", text = "EXPLORADOR", highlight = "Directory", separator = true }
        },
      },
      highlights = {
          fill = { bg = "NONE" },
          background = { bg = "NONE" },
      }
    },
  },

  -- >> INTERFAZ FLOTANTE (Noice + Notify) <<
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
    }
  },

  -- >> BARRA INFERIOR (Lualine) <<
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "pywal",
        globalstatus = true,
        component_separators = '|',
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
        lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
      },
    },
  },

  -- >> EXPLORADOR DE ARCHIVOS (Nvim-Tree) <<
  {
    "nvim-tree/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    keys = {
        { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Abrir/Cerrar Explorador" },
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      view = { width = 30 },
      renderer = { group_empty = true, indent_markers = { enable = true } },
      actions = { 
          open_file = { quit_on_open = false } -- Mantiene el arbol abierto al elegir
      }, 
    },
    config = function(_, opts)
        require("nvim-tree").setup(opts)
        -- Auto-Cerrar si es la ultima ventana
        vim.api.nvim_create_autocmd("QuitPre", {
            callback = function()
                local tree_wins = {}
                local floating_wins = {}
                local wins = vim.api.nvim_list_wins()
                for _, w in ipairs(wins) do
                    local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
                    if bufname:match("NvimTree_") then
                        table.insert(tree_wins, w)
                    end
                    if vim.api.nvim_win_get_config(w).relative ~= '' then
                        table.insert(floating_wins, w)
                    end
                end
                if 1 == #wins - #floating_wins - #tree_wins then
                    for _, w in ipairs(tree_wins) do
                        vim.api.nvim_win_close(w, true)
                    end
                end
            end,
        })
    end
  },

  -- >> MEJORAS VISUALES (Mini.nvim) <<
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {}, -- Autocerrar parentesis () [] {}
  },
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {}, -- Comentar rapido con gcc
  },

  -- >> BUSCADOR (Telescope) <<
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar Archivos" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Buscar Texto" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buscar Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recientes" },
    },
    opts = {
        defaults = {
            prompt_prefix = " ",
            selection_caret = " ",
            layout_strategy = "horizontal",
            sorting_strategy = "ascending",
            layout_config = { prompt_position = "top" },
        },
    },
  },

  -- >> RESALTADO INTELIGENTE (Treesitter) <<
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "bash", "c", "html", "javascript", "json", "lua", "luadoc", "markdown", "markdown_inline", "python", "query", "regex", "rust", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml" },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- >> AUTOCOMPLETADO (CMP) <<
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
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
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), 
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
            format = lspkind.cmp_format({
                mode = 'symbol', 
                maxwidth = 50,
            })
        },
      })
    end,
  },

  -- >> DASHBOARD (Pantalla de Inicio) <<
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local logo = [[
      
         ▄▄▄       ███▄    █  ▄▄▄       ██▀███   ▄████▄   ██░ ██ ▓██   ██▓
        ▒████▄     ██ ▀█   █ ▒████▄    ▓██ ▒ ██▒▒██▀ ▀█  ▓██░ ██▒ ▒██  ██▒
        ▒██  ▀█▄  ▓██  ▀█ ██▒▒██  ▀█▄  ▓██ ░▄█ ▒▒▓█    ▄ ▒██▀▀██░  ▒██ ██░
        ░██▄▄▄▄██ ▓██▒  ▐▌██▒░██▄▄▄▄██ ▒██▀▀█▄  ▒▓▓▄ ▄██▒░▓█ ░██   ░ ▐██▓░
         ▓█   ▓██▒▒██░   ▓██░ ▓█   ▓██▒░██▓ ▒██▒▒ ▓███▀ ░░▓█▒░██▓  ░ ██▒▓░
         ▒▒   ▓▒█░░ ▒░   ▒ ▒  ▒▒   ▓▒█░░ ▒▓ ░▒▓░░ ░▒ ▒  ░ ▒ ░░▒░▒   ██▒▒▒ 
          ▒   ▒▒ ░░ ░░   ░ ▒░  ▒   ▒▒ ░  ░▒ ░ ▒░  ░  ▒    ▒ ░▒░ ░ ▓██ ░▒░ 
          ░   ▒      ░   ░ ░   ░   ▒     ░░   ░ ░         ░  ░░ ░ ▒ ▒ ░░  
              ░  ░         ░       ░  ░   ░     ░ ░       ░  ░  ░ ░ ░     
                                                ░                 ░ ░     
      ]]
      dashboard.section.header.val = vim.split(logo, "\n")
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Buscar Archivo", ":Telescope find_files <CR>"),
        dashboard.button("n", " " .. " Nuevo Archivo", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", " " .. " Recientes", ":Telescope oldfiles <CR>"),
        dashboard.button("q", " " .. " Salir", ":qa<CR>"),
      }
      return dashboard.config
    end,
    config = function(_, dashboard)
      require("alpha").setup(dashboard)
      vim.schedule(function() vim.cmd([[doautocmd User AlphaReady]]) end)
    end,
  },

  { "folke/which-key.nvim", opts = {} },
  { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
  { "stevearc/dressing.nvim", opts = {} },

  -- >> LENGUAJES (LSP) <<
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = { ensure_installed = { "pyright", "lua_ls", "bashls" } }
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = { automatic_installation = true },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
       local lspconfig = require('lspconfig')
       local capabilities = require('cmp_nvim_lsp').default_capabilities()
       
       require("mason-lspconfig").setup_handlers {
           function (server_name)
               lspconfig[server_name].setup {
                   capabilities = capabilities
               }
           end,
       }
    end},
})

-- 4. Keymaps Generales
local map = vim.keymap.set

-- Guardar y Salir
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Guardar Archivo" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Salir de Todo" }) -- ESTA ES LA MAGIA PARA SALIR SIN ERRORES

-- Ventanas
map("n", "<C-h>", "<C-w>h", { desc = "Izquierda" })
map("n", "<C-l>", "<C-w>l", { desc = "Derecha" })
map("n", "<C-j>", "<C-w>j", { desc = "Abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Arriba" })

-- Utilidades
map("n", "<Esc>", "<cmd>nohlsearch<cr>")