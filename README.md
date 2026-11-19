# neovimanu

Config Neovim 0.12 sans LazyVim, gérée par `vim.pack`. Branche `sans-lazyvim` du dépôt
nvim-config, montée en worktree dans `~/dotfiles/neovimanu/.config/neovimanu`
(lien stow `~/.config/neovimanu`). Elle cohabite avec l'ancienne config (`nvim`).

## Lancer

```sh
nn                      # alias de NVIM_APPNAME=neovimanu nvim : page d'accueil
nn ~/Projects/lama/     # se place dans lama et affiche l'accueil
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

## Documentation

- `MANUEL.md` : comment s'en servir (`<leader>M` dans Neovim, `<leader>H` dans le navigateur).
- `KEYMAPS.md` : tous les raccourcis (`<leader>K`).
- `docs/tri.md` : ce qui a été repris de l'ancienne config LazyVim (généré par
  `tools/inventaire.lua`).

## Tests

- `tests/run.sh` : specs headless (`tests/*_spec.lua`), rapides.
- `tests/first_run.sh` : installation complète dans un dossier vide puis second démarrage
  sans erreur (réseau, ~1 min).
- `tests/real_projects.sh <projet>` : contrôle sur un vrai projet PHP/Symfony (ex. lama) —
  Intelephense, `gd`, PHPStan dans le conteneur, neotest, symfony-lsp. Lent, ne modifie rien.

## Projets dockerisés

Un `.nvim/docker.lua` à la racine d'un projet fait tourner ses outils (php-cs-fixer,
PHPStan, PHPUnit, console, composer, outils JS) dans son conteneur. `:Projet` affiche ce qui
est détecté pour le fichier courant. Détails : `MANUEL.md`, section 12.

Démarrage mesuré (headless, `--startuptime`) : **~95 ms** le 2026-11-12 (socle), **~110 ms** le 2026-11-19 (avec PHP/Symfony et JS/TS/Vue).
