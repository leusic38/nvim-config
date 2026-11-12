-- Racine du projet (remplace LazyVim.root) : premier dossier parent contenant .git,
-- composer.json ou package.json ; sinon le dossier courant.
-- Utilisé par fzf-lua (recherches « Root Dir »), le terminal, lazygit.
---@param bufnr? integer
---@return string
return function(bufnr)
  return vim.fs.root(bufnr or 0, { ".git", "composer.json", "package.json" }) or vim.uv.cwd()
end
