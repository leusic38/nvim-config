#!/usr/bin/env bash
# Lance chaque tests/*_spec.lua dans un nvim headless (NVIM_APPNAME=neovimanu).
# Usage : tests/run.sh [motif]   — motif : ne lance que les specs dont le nom le contient.
# Un spec dont la première ligne est « -- args: <fichiers> » reçoit ces fichiers en argument.
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
  fi
  out="$(NVIM_APPNAME=neovimanu timeout 120 nvim --headless "${args[@]}" \
    --cmd "lua package.path = '$root/tests/?.lua;' .. package.path" \
    -c "luafile $spec" 2>&1)"
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
