return {
  {
    "AlphaTechnolog/pywal.nvim",
    name = "pywal",
    lazy = false,
    priority = 1000,
    config = function()
      local pywal = require("pywal")
      local lualine_exist, lualine = pcall(require, "lualine")

      -- 1. Configuración inicial
      pywal.setup()
      vim.cmd.colorscheme("pywal")

      -- 2. Función para recargar todo "a la fuerza"
      local function reload_colors()
        -- Limpiar la caché de Lua para que lea el nuevo archivo JSON
        for k, _ in pairs(package.loaded) do
          if k:match("^pywal") then
            package.loaded[k] = nil
          end
        end

        -- Volver a cargar y aplicar
        require("pywal").setup()
        vim.cmd.colorscheme("pywal")

        -- Recargar Lualine si existe
        if lualine_exist then
          lualine.refresh()
        end
      end

      -- 3. Crear el vigilante de archivos (File Watcher)
      -- Detecta cambios en ~/.cache/wal/colors.json
      local wal_cache = os.getenv("HOME") .. "/.cache/wal/colors.json"
      local w = vim.uv.new_fs_event()

      -- Iniciar vigilancia
      w:start(
        wal_cache,
        {},
        vim.schedule_wrap(function()
          reload_colors()
        end)
      )
    end,
  },

  -- Configuración de Lualine
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = "pywal"
    end,
  },
}
