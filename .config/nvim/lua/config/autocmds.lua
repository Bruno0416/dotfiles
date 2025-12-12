-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- Recargar Pywal al recibir la señal SIGUSR1
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    -- 1. Recargar los módulos de pywal para leer la nueva caché
    package.loaded["pywal"] = nil
    package.loaded["pywal.core"] = nil
    package.loaded["pywal.util"] = nil

    -- 2. Volver a iniciar el setup y el esquema
    require("pywal").setup()
    vim.cmd.colorscheme("pywal")

    -- 3. (Opcional) Forzar refresco de Lualine si no cambia solo
    -- require("lualine").refresh()
  end,
})
