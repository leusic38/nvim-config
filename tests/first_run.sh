#!/usr/bin/env bash
# Premier lancement sur un stdpath("data") vide : tous les plugins s'installent sans question,
# puis un second lancement démarre sans erreur. Réseau requis, lent : hors de tests/run.sh.
set -u
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export NVIM_APPNAME=neovimanu XDG_DATA_HOME="$tmp/data" XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache"
check='lua if vim.v.errmsg ~= "" then io.stdout:write("errmsg : " .. vim.v.errmsg .. "\n") vim.cmd("cquit 1") else vim.cmd("qa!") end'

echo "1er lancement (installation)…"
timeout 600 nvim --headless -c "$check" 2>&1 | tail -5
first=${PIPESTATUS[0]}
echo "2e lancement…"
out="$(timeout 120 nvim --headless -c "$check" 2>&1)"
second=$?
[[ -n "$out" ]] && printf '%s\n' "$out"
if [[ $second -eq 0 ]]; then
  echo "OK   first_run (1er : code $first, 2e : code 0)"
else
  echo "FAIL first_run (2e lancement : code $second)"
fi
exit $second
