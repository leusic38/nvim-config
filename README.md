# neovimanu

Config Neovim 0.12 sans LazyVim, gérée par `vim.pack`. Branche `sans-lazyvim` du dépôt
nvim-config, montée en worktree dans `~/dotfiles/neovimanu/.config/neovimanu`
(lien stow `~/.config/neovimanu`). Elle cohabite avec l'ancienne config (`nvim`).

## Lancer

```sh
nn            # alias de NVIM_APPNAME=neovimanu nvim
```

## Tests

```sh
tests/run.sh            # tous les tests headless (tests/*_spec.lua)
tests/run.sh keymaps    # seulement les specs dont le nom contient « keymaps »
VERBOSE=1 tests/run.sh  # affiche aussi la sortie des specs qui passent
```

## Mettre à jour les plugins

`:lua vim.pack.update()` ouvre un buffer de revue des changements ; `:write` les applique,
`:quit` annule. Le lockfile `nvim-pack-lock.json` est commité : le commiter après chaque mise à jour.

## Règle des raccourcis

Un raccourci = **une seule déclaration** dans `lua/manu/*.lua`, avec une `desc`, **et une ligne
dans `KEYMAPS.md`**. `tests/run.sh keymaps` vérifie que les deux correspondent et qu'aucun
plugin ne pose de raccourci global non déclaré.
