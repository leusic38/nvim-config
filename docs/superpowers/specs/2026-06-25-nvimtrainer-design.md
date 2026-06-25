# NvimTrainer — Design (Phase A + B)

**Date**: 2026-06-25
**Status**: Validated, ready for implementation plan

## Objectif

Outil local d'entraînement à Neovim. Propose des exercices interactifs qui
couvrent **vim de base** (motions, text objects, ex commands) **et les keymaps
perso** de cette config. L'utilisateur exécute l'action dans un vrai buffer ; le
plugin vérifie le résultat.

Cet outil est conçu en plusieurs pièces. Ce spec couvre les deux premières :

- **A. Corpus** — données d'exercices (fondation, lue par tout le reste).
- **B. Plugin nvim interactif** — le moteur : tâche réelle dans un buffer
  jetable, action de l'utilisateur, vérification hybride.

**Hors scope (versions futures)** : C. daily prompt au démarrage, D. quiz CLI,
E. cheatsheet/flashcards générées, extraits de fichiers projet réels comme
support, répétition espacée type SM-2.

## Décisions clés

| Sujet | Choix |
|---|---|
| Ordre de build | A (corpus) puis B (plugin) ; C/D/E réutilisent A+B plus tard |
| Vérification | **Hybride** : état final décide la réussite ; touches pressées = bonus technique non-bloquant |
| Stockage corpus | Tables Lua manuelles (vim de base) + **auto-extraction** des keymaps perso depuis `vim.api.nvim_get_keymap` |
| Surface de pratique | Buffer **scratch** jetable (zéro risque fichiers réels) — extensible plus tard |
| Suivi progrès | JSON local simple (réussite/échec, streak, priorise points faibles) — pas de SM-2 |
| Validation d'un exo | **Auto-détection** quand le buffer atteint l'état cible ; pour exos keymaps, quand la touche attendue est pressée ; `<localleader>v` en secours manuel |

## Architecture & arborescence

Plugin LazyVim local, sans dépendance externe.

```
lua/
  nvimtrainer/
    init.lua          -- setup(), commandes :NvimTrainer*
    corpus/
      init.lua        -- charge + fusionne toutes les sources
      motions.lua     -- exos vim de base (tables Lua, à la main)
      textobjects.lua
      excmd.lua
      keymaps.lua     -- AUTO: génère exos depuis vim.api.nvim_get_keymap
    engine.lua        -- ouvre scratch, lance exo, capture touches
    verify.lua        -- compare état cible + séquence touches
    session.lua       -- UI float: titre, consigne, feedback, navigation
    progress.lua      -- lit/écrit JSON progrès, sélection pondérée
  plugins/
    nvimtrainer.lua   -- spec lazy.nvim (active le plugin local)
```

Chaque module = un rôle clair, testable isolément.

### Flux

`:NvimTrainerStart [category]`
→ `progress` choisit un exo (pondéré vers les points faibles / jamais vus)
→ `engine` ouvre le scratch, seed le buffer + curseur, applique le filetype
→ `vim.on_key` enregistre les touches
→ l'utilisateur agit
→ auto-détection (buffer == cible, ou touche attendue pressée) ou `<localleader>v`
→ `verify` compare état + touches
→ `session` affiche le feedback (✓ état, ✓/○ technique)
→ exo suivant

## Schéma d'un exercice

```lua
{
  id = "to-diw-01",            -- unique, clé du suivi progrès
  title = "Supprimer le mot sous le curseur",
  category = "textobjects",    -- motions | textobjects | excmd | keymaps
  difficulty = 2,              -- 1..5
  hint = "text object 'inner word'",
  filetype = "text",           -- coloration du scratch
  start_lines = { "le chat noir dort" },
  start_cursor = { 1, 7 },     -- {ligne 1-based, col 0-based} (convention API nvim)
  target_lines = { "le  noir dort" },
  target_cursor = nil,         -- optionnel ; nil = curseur ignoré
  expected_keys = "diw",       -- bonus technique ; nil = pas de check touches
}
```

### Corpus — sources

- **Vim de base** (`motions.lua`, `textobjects.lua`, `excmd.lua`) : écrits à la
  main, ~10–15 exos par catégorie pour démarrer.
- **Keymaps perso** (`keymaps.lua`) : lit `vim.api.nvim_get_keymap(mode)`, filtre
  ceux avec un `desc` non vide, génère des exos du type *« Quel raccourci pour :
  `<desc>` ? Exécute-le »* avec `expected_keys = lhs`. La vérification repose sur
  la touche pressée (pas de changement de buffer). Toujours synchro avec la config.

### Validation requise du corpus

- Tout exo possède les champs requis (`id`, `title`, `category`, `difficulty`,
  `start_lines`).
- Les `id` sont uniques sur l'ensemble du corpus fusionné.

## Moteur (engine.lua)

- Ouvre un buffer scratch : `buftype=nofile`, `bufhidden=wipe`, `swapfile=off`,
  dans un split/onglet dédié.
- Seed `start_lines`, place le curseur à `start_cursor`, applique `filetype`.
- Capture des touches : `vim.on_key(cb, ns)` accumule les touches jusqu'à la
  validation, puis retire le callback (`vim.on_key(nil, ns)`).
- Filtre la touche de validation du trainer hors du log de touches.

## Vérification (verify.lua)

- `state_ok` = `target_lines` == lignes du buffer (+ curseur si `target_cursor`
  non-nil).
- `keys_ok` = séquence capturée normalisée == `expected_keys` (si défini).
- Retourne `{ passed = state_ok, technique = keys_ok }`.
- **`passed` (état) seul décide de la réussite.** Les touches sont un bonus
  informatif : vert si match exact, gris sinon, mais l'exo est validé dès que
  l'état est correct. Évite la rigidité (`daw`, `2dw`… restent acceptés).

## UI de session (session.lua)

Float style Telescope/fzf (cohérent avec la config).

- Header : titre + catégorie + difficulté.
- Consigne + `hint` (révélable sur touche).
- Feedback après validation :
  - `✓ Résultat correct` / `✗ Pas encore` (+ diff attendu/obtenu).
  - `✓ Technique optimale (diw)` / `○ Autre méthode (attendu: diw)`.
- Actions : `n` suivant · `r` recommencer · `s` solution · `q` quitter.

## Commandes

- `:NvimTrainerStart [category]` — démarre une session, filtre de catégorie optionnel.
- `:NvimTrainerStop` — arrête la session, nettoie scratch + callback.
- `:NvimTrainerStats` — résumé (streak, % réussite, points faibles).

## Progrès (progress.lua)

- Fichier : `vim.fn.stdpath("data") .. "/nvimtrainer/progress.json"`.
- Par exo : `{ seen, passed, failed, last_ts, technique_hits }`.
- Sélection pondérée : exos jamais vus + souvent ratés = priorité haute. Pioche
  pondérée simple (pas de SM-2 dans cette phase).

## Tests

- `verify.lua` et `progress.lua` = logique pure → tests automatiques
  (busted/plenary), sans UI.
- `corpus` : test des champs requis + unicité des `id`.
- `engine` / `session` (UI) : test manuel, pas automatique.

## Keymaps à documenter

Toute nouvelle keymap (ex. `<localleader>v` dans le scratch, raccourci d'ouverture
de session) doit être ajoutée à `KEYMAPS.md` (source de vérité unique) et vérifiée
contre les conflits, conformément au CLAUDE.md du repo.
