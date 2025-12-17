return {
  {
    "AlphaTechnolog/pywal.nvim",
    name = "pywal",
    lazy = false,
    priority = 1000,
    config = function()
      local pywal = require("pywal")

      -- 1. Configuración inicial
      pywal.setup()
      vim.cmd.colorscheme("pywal")

      -- 2. Función para recargar todo
      local function reload_colors()
        -- Limpiar caché
        for k, _ in pairs(package.loaded) do
          if k:match("^pywal") then
            package.loaded[k] = nil
          end
        end

        -- Recargar Pywal
        require("pywal").setup()
        vim.cmd.colorscheme("pywal")

        if package.loaded["lualine"] then
          require("lualine").refresh()
        end
      end

      -- 3. Watcher
      local wal_cache = os.getenv("HOME") .. "/.cache/wal/colors.json"
      local w = vim.uv.new_fs_event()

      w:start(
        wal_cache,
        {},
        vim.schedule_wrap(function()
          reload_colors()
        end)
      )
    end,
  },

  -- Configuración de Lualine (Integración correcta con LazyVim)
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "pywal"
    end,
  },
}
