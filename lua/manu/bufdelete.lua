-- Fermer des buffers sans fermer leurs fenêtres (remplace Snacks.bufdelete).
-- Utilisé par keymaps.lua (<leader>bd/bo/bi) et bufferline (fermeture à la souris, <leader>bl/br).
local M = {}

--- Ferme un buffer sans fermer ses fenêtres (elles passent au buffer alterné ou précédent).
function M.delete(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  if vim.bo[buf].modified then
    local choice = vim.fn.confirm(
      ("Enregistrer les modifications de %q ?"):format(vim.fn.bufname(buf)),
      "&Oui\n&Non\n&Annuler"
    )
    if choice == 0 or choice == 3 then
      return
    elseif choice == 1 then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("write")
      end)
    end
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      local alt = vim.fn.bufnr("#")
      if alt ~= buf and alt > 0 and vim.fn.buflisted(alt) == 1 then
        vim.api.nvim_win_set_buf(win, alt)
      else
        pcall(vim.cmd, "bprevious")
      end
      if vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
      end
    end)
  end
  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.cmd, "bdelete! " .. buf)
  end
end

--- Ferme les buffers listés qui vérifient pred(buf).
function M.where(pred)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted and pred(b) then
      M.delete(b)
    end
  end
end

return M
