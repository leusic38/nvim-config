#!/usr/bin/env bash
# Lance chaque tests/*_spec.lua dans un nvim headless (NVIM_APPNAME=neovimanu).
# Usage : tests/run.sh [motif]   — motif : ne lance que les specs dont le nom le contient.
# Un spec dont la première ligne est « -- args: <fichiers> » reçoit ces fichiers en argument ;
# « -- verbose » lance nvim avec verbose=1 (nvim note alors l'origine des raccourcis).
set -u
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit 1
pattern="${1:-}"
status=0
for spec in tests/*_spec.lua; do
  name="$(basename "$spec")"
  [[ -n "$pattern" && "$name" != *"$pattern"* ]] && continue
  args=()
  first="$(head -n1 "$spec")"
  if [[ "$first" == "-- args: "* ]]; then
    read -r -a args <<< "${first#-- args: }"
  elif [[ "$first" == "-- verbose" ]]; then
    args=(--cmd "set verbose=1")
  fi
  # pcall : une erreur Lua dans le spec ne doit pas laisser nvim headless en attente.
  out="$(NVIM_APPNAME=neovimanu timeout 90 nvim --headless "${args[@]}" \
    --cmd "lua package.path = '$root/tests/?.lua;' .. package.path" \
    -c "lua local ok, err = pcall(dofile, '$spec') if not ok then io.stdout:write('  erreur : ' .. tostring(err) .. '\\n') vim.cmd('cquit 2') end" \
    2>&1)"
  code=$?
  if [[ $code -eq 0 ]]; then
    echo "OK   $name"
  else
    echo "FAIL $name (code $code)"
    status=1
  fi
  [[ -n "$out" && ( $code -ne 0 || -n "${VERBOSE:-}" ) ]] && printf '%s\n' "$out"
done
exit $status
