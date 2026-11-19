#!/usr/bin/env bash
# Contrôle scripté de la config sur un vrai projet PHP/Symfony (ex. lama). Hors tests/run.sh :
# lent (indexation Intelephense), dépend du projet et de son conteneur. Ne modifie rien dans
# le projet (aucun enregistrement de fichier).
#
# Usage : tests/real_projects.sh ~/Projects/lama
set -u
project="${1:?usage: tests/real_projects.sh <dossier du projet>}"
project="$(cd "$project" && pwd)"
here="$(cd "$(dirname "$0")" && pwd)"
cd "$project" || exit 1

# Un fichier PHP de src/ qui importe une classe du projet (use <Namespace>\…).
php_file="$(grep -rlE '^use [A-Z][A-Za-z]+\\' src --include='*.php' 2>/dev/null | head -1)"
yaml_file="$(find config src \( -name 'services.yaml' -o -name 'services.yml' \) 2>/dev/null | head -1)"
test_file="$(grep -rlE 'extends (TestCase|KernelTestCase|WebTestCase)' tests --include='*Test.php' 2>/dev/null | head -1)"
echo "Projet  : $project"
echo "PHP     : ${php_file:-(aucun)}"
echo "YAML    : ${yaml_file:-(aucun)}"
echo "Test    : ${test_file:-(aucun)}"
export MANU_REAL_YAML="$yaml_file" MANU_REAL_TEST="$test_file"

NVIM_APPNAME=neovimanu timeout 900 nvim --headless -i NONE -n "$php_file" \
  -c "lua vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = vim.schedule_wrap(function() dofile('$here/real_projects.lua') end) })" 2>&1

# neotest, dans un Neovim à part ouvert sur le fichier de test.
if [ -n "$test_file" ]; then
  NVIM_APPNAME=neovimanu timeout 180 nvim --headless -i NONE -n "$test_file" \
    -c "lua vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = vim.schedule_wrap(function()
      local nt = require('neotest')
      local buf = vim.api.nvim_get_current_buf()
      nt.summary.open()
      local tree
      vim.wait(120000, function()
        for _, id in ipairs(nt.state.adapter_ids()) do
          tree = nt.state.positions(id, { buffer = buf })
          if tree then return true end
        end
      end, 500)
      local n = 0
      if tree then for _, p in tree:iter() do if p.type == 'test' then n = n + 1 end end end
      io.stdout:write(('neotest : %d test(s) trouvé(s) dans %s (adaptateurs : %s)\\n'):format(n, '$test_file', table.concat(nt.state.adapter_ids(), ', ')))
      vim.cmd('qa!')
    end) })" 2>&1 | grep '^neotest'
fi
