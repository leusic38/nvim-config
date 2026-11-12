# 📘 Manuel de neovimanu

> Neovim 0.12 **sans LazyVim** : `vim.pack`, LSP natif, une config qu'on lit de bout en bout.
> Ce manuel couvre le **socle** (édition générale, Lua, navigation, Git, terminal, IA) ;
> les langages (PHP/Symfony, JS/TS/Vue, SQL, Docker…) arrivent avec les plans suivants.
> **Leader** = `<Space>` (espace). La liste exhaustive des raccourcis est dans
> [`KEYMAPS.md`](KEYMAPS.md) (ou `<leader>K` dans Neovim).
> Lancer : `nn` (alias de `NVIM_APPNAME=neovimanu nvim`).

---

## Sommaire

1. [Survivre : les raccourcis à connaître](#1-survivre--les-raccourcis-à-connaître)
2. [Trouver son chemin](#2-trouver-son-chemin)
3. [Fichiers et explorateur (Oil)](#3-fichiers-et-explorateur-oil)
4. [Fenêtres, buffers, onglets](#4-fenêtres-buffers-onglets)
5. [Éditer et coder](#5-éditer-et-coder)
6. [Formatage et lint](#6-formatage-et-lint)
7. [Terminal](#7-terminal)
8. [Git](#8-git)
9. [Claude : IA et agents parallèles](#9-claude--ia-et-agents-parallèles)
10. [Entretien de la config](#10-entretien-de-la-config)
11. [Ajouter un langage](#11-ajouter-un-langage)
12. [Dépannage](#12-dépannage)

---

## 1. Survivre : les raccourcis à connaître

| Raccourci                 | Ce que ça fait                                   |
| ------------------------- | ------------------------------------------------ |
| `<leader><Space>`         | Trouver un fichier                               |
| `<leader>/`               | Chercher du texte dans tout le projet            |
| `-`                       | Ouvrir le dossier du fichier courant (Oil)       |
| `gd` / `gr`               | Aller à la définition / voir les références      |
| `K`                       | Documentation sous le curseur                    |
| `<leader>ca`              | Actions de code (imports, quick-fix…)            |
| `<C-Bslash>`              | Terminal flottant persistant (`Ctrl+\`)          |
| `<leader>gg`              | Lazygit                                          |
| `<leader>as`              | Claude du projet courant                         |
| `<leader>K`               | Afficher `KEYMAPS.md` dans une fenêtre flottante |
| `<leader>M` / `<leader>H` | Ce manuel, dans Neovim / dans le navigateur      |

> 💡 **Le réflexe n°1** : appuyer sur `<leader>` et **attendre**. which-key affiche les
> suites possibles, groupées par lettre (`f` fichiers, `s` recherche, `g` git, `c` code,
> `x` diagnostics, `u` interface, `a` IA, `b` buffers, `q` sessions…).

---

## 2. Trouver son chemin

- **which-key** : taper un préfixe (`<leader>`, `g`, `]`, `z`…) et attendre.
  `<leader>?` montre les raccourcis propres au buffer courant.
- **`<leader>sk`** : recherche floue dans *tous* les raccourcis actifs.
- **`<leader>K`** : `KEYMAPS.md` en lecture seule, `q` ou `Échap` pour fermer.
- **`<leader>M`** : ce manuel en flottant (`/` pour chercher une section).
- **`<leader>H`** : ce manuel dans le navigateur (via `mdview`).
- **`<leader>sh`** : l'aide de Neovim.

### Recherche (fzf-lua)

| Raccourci         | Recherche                                     |
| ----------------- | --------------------------------------------- |
| `<leader><Space>` | Fichiers (racine du projet)                   |
| `<leader>fr`      | Fichiers récents                              |
| `<leader>/`       | Grep dans le projet                           |
| `<leader>sw`      | Le mot sous le curseur (ou la sélection)      |
| `<leader>sr`      | Rechercher / remplacer dans le projet         |
| `<leader>ss`      | Symboles du fichier (classes, méthodes…)      |
| `<leader>sS`      | Symboles de tout le projet                    |
| `<leader>sR`      | Reprendre la dernière recherche               |

La **racine du projet** est le premier dossier parent qui contient `.git`,
`composer.json` ou `package.json` (sinon le dossier courant).

La recherche de fichiers **inclut les fichiers cachés et ignorés par git**, mais exclut
`vendor`, `node_modules`, `dist`, `build`, `cache`, `.git` et `.claude`. Elle est
insensible à la casse et affiche le nom du fichier avant son chemin.

Toutes les listes de choix de Neovim (actions de code, worktrees…) passent aussi par fzf-lua.

---

## 3. Fichiers et explorateur (Oil)

Oil remplace netrw et neo-tree : **un dossier s'édite comme un buffer texte**.

- `-` ouvre le dossier parent dans la fenêtre courante, `<leader>e` en flottant.
- Renommer = éditer la ligne. Supprimer = `dd`. Créer = écrire une nouvelle ligne
  (finir par `/` pour un dossier). Déplacer = couper/coller une ligne.
- **Rien n'est appliqué tant qu'on n'a pas enregistré** (`:w` ou `<C-s>`), Oil demande
  alors confirmation.
- `Entrée` ouvre, `<A-v>` en découpage vertical, `<A-h>` en horizontal, `g?` l'aide.
- Les fichiers cachés sont visibles ; seul `.git` est toujours masqué.

| Raccourci    | Action                                       |
| ------------ | -------------------------------------------- |
| `<leader>fn` | Nouveau fichier (demande le nom)             |
| `<leader>yn` | Copier le nom du fichier                     |
| `<leader>yp` | Copier le chemin relatif                     |
| `<leader>yP` | Copier le chemin absolu                      |
| `<leader>yc` | Copier une référence `@fichier#L10-20` pour Claude |

---

## 4. Fenêtres, buffers, onglets

- **Fenêtres** : `<C-h>` `<C-j>` `<C-k>` `<C-l>` pour se déplacer (marche aussi depuis le
  terminal), `<leader>-` / `<leader><Bar>` (`|`) pour découper, `<leader>wd` pour fermer,
  `<C-Up>` `<C-Down>` `<C-Left>` `<C-Right>` pour redimensionner. `<C-w><Space>` garde le
  menu des fenêtres ouvert pour enchaîner plusieurs commandes.
- **Buffers** : `<S-h>` / `<S-l>` précédent/suivant, `<leader>,` pour choisir dans une
  liste, `<leader>bj` pour choisir par lettre, `<leader>bd` fermer (la fenêtre reste),
  `<leader>bo` fermer tous les autres, `<leader>bp` épingler.
- **Onglets** (`<leader><Tab><Tab>` nouveau, `<leader><Tab>]` suivant…) : utilisés surtout pour Claude et les **worktrees** —
  chaque onglet de worktree a son propre dossier courant (`:tcd`), voir §9.
- **Sessions** : `<leader>qs` restaure la session du dossier courant (buffers, fenêtres),
  `<leader>ql` la dernière, `<leader>qd` n'enregistre pas celle-ci.

---

## 5. Éditer et coder

### Petits plus perso

| Raccourci      | Action                                          |
| -------------- | ----------------------------------------------- |
| `<CR>`         | Insérer une ligne vide en dessous (mode normal) |
| `<S-CR>`       | Insérer une ligne vide au-dessus                |
| `<C-a>`        | Tout sélectionner                               |
| `p` (visuel)   | Coller **sans** écraser le registre             |
| `<A-j>`/`<A-k>` | Déplacer la ligne / la sélection               |
| `gcc` / `gc`   | Commenter ligne / sélection ou mouvement (natif) |
| `gco` / `gcO`  | Ajouter un commentaire en dessous / au-dessus   |
| `<C-s>`        | Enregistrer                                     |

### Se déplacer vite (flash) et sélectionner

- `s` + 2 lettres : des étiquettes apparaissent, taper celle de la cible.
- `S` : choisir un nœud Treesitter (fonction, bloc, argument…) par étiquette.
- `<C-Space>` : sélection incrémentale, chaque `<C-Space>` étend au nœud parent, `<BS>`
  revient en arrière.
- `f` `t` `F` `T` sautent aussi sur les lignes suivantes ; `;` / `,` répètent.
- Objets textuels (mini.ai) : `af`/`if` fonction, `ac`/`ic` classe, `aa`/`ia` argument,
  `ao` bloc, `at` balise, `au` appel de fonction, `ag` tout le buffer. Exemple : `vaf`
  sélectionne la fonction, `dia` supprime un argument.
- Treesitter : `]f`/`[f` fonction suivante/précédente, `]c`/`[c` classe, `]a`/`[a` paramètre.

### LSP (tous langages)

Les touches natives de Neovim 0.12 restent : `grn` renommer, `gra` actions, `grr`
références, `gri` implémentation, `grt` type, `gO` symboles. S'y ajoutent les touches de
LazyVim :

| Raccourci    | Action                         |
| ------------ | ------------------------------ |
| `gd`         | Définition                     |
| `gr`         | Références                     |
| `gI` / `gy`  | Implémentation / type          |
| `K`          | Documentation                  |
| `<leader>ca` | Actions de code                |
| `<leader>cr` | Renommer le symbole            |
| `<leader>cR` | Renommer le fichier (les imports suivent) |
| `<leader>co` | Organiser les imports          |
| `<leader>cf` | Formater                       |
| `]d` `[d`    | Diagnostic suivant / précédent |
| `]e` `]w`    | Erreur / avertissement suivant |
| `<leader>cd` | Diagnostics de la ligne        |
| `<leader>xx` | Liste des diagnostics (Trouble) |
| `]]` `[[`    | Occurrence suivante / précédente du symbole |

Les diagnostics s'affichent **en fin de ligne**. `<leader>ud` les masque,
`<leader>uh` bascule les indices inline (types, noms de paramètres).

### Complétion

blink.cmp propose LSP, chemins, snippets et mots du buffer. `<CR>` accepte,
`<C-Space>` ouvre le menu, `<C-n>`/`<C-p>` naviguent, `<Tab>` saute au champ suivant d'un
snippet. Pas d'IA dans la complétion : l'IA passe par Claude (§9).

### Refactoring (langages Treesitter)

Groupe refactoring, surtout **en mode visuel** sur une sélection : `<leader>Rm` menu,
`<leader>Re` extraire en fonction, `<leader>Rf` extraire dans un fichier,
`<leader>Rv` extraire en variable, `<leader>Ri` inliner une variable.

### Rechercher / remplacer dans le projet

`<leader>sr` ouvre grug-far (prérempli avec l'extension du fichier courant) : taper la
recherche et le remplacement, l'aperçu se met à jour, puis appliquer depuis le buffer.

### TODO

`]t` / `[t` parcourent les `TODO:`, `FIX:`, `NOTE:`… ; `<leader>st` les liste (fzf),
`<leader>xt` dans Trouble.

### Orthographe (FR + EN)

Désactivée par défaut (activée d'office en Markdown et dans les messages de commit),
`<leader>us` pour l'activer. Puis `]s`/`[s` pour naviguer, `z=` suggestions, `zg`
ajouter au dictionnaire.

---

## 6. Formatage et lint

**Règle : on ne formate à l'enregistrement que si le projet contient la config du
formateur.** Un projet sans `stylua.toml` garde son style : rien n'est réécrit en masse à
la première sauvegarde.

| Langage | Formatage                                  | Lint |
| ------- | ------------------------------------------ | ---- |
| Lua     | stylua **si `stylua.toml` / `.stylua.toml`** | lua_ls (diagnostics LSP) |

Les plans suivants ajoutent PHP (php-cs-fixer, PHPStan), JS/TS/Vue (Prettier, ESLint),
Twig, SQL… avec la même règle.

- `<leader>uf` coupe/rétablit le formatage à l'enregistrement **partout** ;
  `<leader>uF` **pour le buffer courant** seulement (prioritaire sur le global).
- `<leader>cf` formate à la demande (via le serveur LSP s'il n'y a pas de formateur).
- Le lint (nvim-lint) tourne à l'ouverture, à l'enregistrement et en quittant l'insertion.
- YAML : toujours 2 espaces, même si le `.editorconfig` du projet dit 4.

---

## 7. Terminal

- `<C-Bslash>` (`Ctrl+\`) ouvre/ferme un **terminal flottant persistant** : l'historique
  et la sortie restent quand on le ferme.
- `<leader>th` / `<leader>tv` : terminal en bas / à droite. `<leader>ft` terminal à la
  racine du projet, `<leader>fT` dans le dossier courant.
- Dans le terminal : `Échap` **ferme la fenêtre** (le terminal continue de tourner),
  `<C-Space>` passe en mode normal sans fermer (pour copier, utiliser `<leader>`…),
  `<C-h>` `<C-j>` `<C-k>` `<C-l>` changent de fenêtre.
- `<leader>od` ouvre **lazydocker** en plein écran, à la racine du projet (il y trouve le
  `docker-compose.yml`). `?` pour l'aide, `q` pour revenir.

---

## 8. Git

| Raccourci     | Action                                       |
| ------------- | -------------------------------------------- |
| `<leader>gg`  | **Lazygit** (racine du projet)               |
| `<leader>gd`  | Diffview : fichiers modifiés vs HEAD (suivis seulement ; avec les non suivis : `:DiffviewOpen --untracked-files=all`) |
| `<leader>gD`  | Fermer Diffview                              |
| `<leader>gF`  | Historique du fichier avec diff (Diffview)   |
| `<leader>gf`  | Historique du fichier (fzf)                  |
| `<leader>gs`  | Statut (fzf)                                 |
| `<leader>gb`  | Blame de la ligne                            |
| `]h` / `[h`   | Hunk suivant / précédent                     |
| `<leader>ghs` | Indexer le hunk (`<leader>ghr` l'annuler, `<leader>ghp` l'aperçu) |
| `<leader>gc`  | Dans un message de commit : choisir un type *Conventional Commits* |

### 8.1 Lazygit au quotidien

`<leader>gg` ouvre lazygit en plein écran **dans Neovim** (racine du dépôt ;
`<leader>gG` pour le dossier courant). `q` pour quitter, **`?` affiche l'aide du panneau
courant** : en cas de doute, c'est le réflexe.

**Les panneaux** — `1` à `5` ou `Tab`/`h`/`l` pour passer de l'un à l'autre, `j`/`k`
pour se déplacer dedans :

| N° | Panneau  | Ce qu'on y fait                               |
| -- | -------- | --------------------------------------------- |
| 1  | Status   | Dépôt courant, `Entrée` pour changer de dépôt |
| 2  | Files    | Indexer, commiter, résoudre les conflits      |
| 3  | Branches | Checkout, créer, merger, rebaser              |
| 4  | Commits  | Historique, reword, squash, fixup, revert     |
| 5  | Stash    | Appliquer / supprimer des stashs              |

**Commiter (panneau Files)** : `espace` indexe/désindexe le fichier, `a` tout,
`Entrée` entre dans le fichier pour indexer **ligne par ligne**, `c` commit (popup),
`C` commit dans l'éditeur, `A` amender, `d` annuler les modifications (⚠️ définitif),
`e` éditer le fichier dans Neovim, `s` stasher.

**Synchroniser** : `f` fetch, `p` pull, `P` push.

**Branches (panneau 3)** : `espace` checkout, `n` nouvelle branche, `M` merger dans la
courante, `r` rebaser la courante dessus, `R` renommer, `d` supprimer.

**Réécrire l'historique (panneau 4)**, seulement sur des commits non poussés :
`r`/`R` reword, `s` squash, `f` fixup, `d` supprimer, `Ctrl-j/k` déplacer, `e` s'arrêter
dessus (rebase interactif), `t` revert, `g` reset.

> 🛟 **`z` annule la dernière action** (et `Z` la refait), grâce au reflog.

### 8.2 Résoudre un conflit

Git laisse dans les fichiers des marqueurs `<<<<<<<`, `=======`, `>>>>>>>`.

> ⚠️ **Ours / theirs s'inversent pendant un rebase** : en merge, *ours* = la branche
> courante ; en rebase, *ours* = la branche **sur laquelle** on rebase (ex. `main`) et
> *theirs* = **ses** commits rejoués.

**Dans lazygit (conflits simples)** : panneau Files, `Entrée` sur un fichier en conflit,
`←`/`→` conflit précédent/suivant, `↑`/`↓` choisir le bloc, `espace` le garder, `b`
garder les deux. Puis `m` → *continue* (ou *abort*).

**Dans Diffview (conflits complexes)** : `<leader>gd`, chaque fichier en conflit s'ouvre
en 3 colonnes (*ours*, résultat au centre, *theirs*). Dans le fichier central : `]x`/`[x`
conflit suivant/précédent, `<leader>co` garder ours, `<leader>ct` theirs, `<leader>cb`
base, `<leader>ca` les deux, `dx` aucun (majuscules `<leader>cO`… pour tout le fichier).
Enregistrer, `-` dans le panneau de fichiers pour indexer, `<leader>gD` pour fermer, puis
`m` → *continue* dans lazygit.

> ⚠️ Dans un buffer de conflit Diffview, `<leader>ca` / `<leader>co` sont les touches de
> Diffview, pas « actions de code » / « organiser les imports ».

> 💡 `git config --global merge.conflictstyle zdiff3` ajoute la version de l'ancêtre
> commun dans les marqueurs : très utile pour comprendre ce que chaque côté a changé.

---

## 9. Claude : IA et agents parallèles

### a) Lancement ponctuel (onglet terminal)

| Raccourci     | Action                                                      |
| ------------- | ----------------------------------------------------------- |
| `<leader>aa`  | Claude dans un nouvel onglet                                |
| `<leader>ap`  | **Expert auto** : détecte les stacks du projet et se lance depuis sa racine (lit le `CLAUDE.md`) |
| `<leader>aep` | Expert forcé PHP (`<leader>aej` JS, `<leader>aek` Kotlin, `<leader>aet` Terraform) |
| `<leader>aq`  | Envoyer la sélection (visuel)                               |
| `<leader>ar`  | Revue de code du fichier courant                            |

### b) Un agent par worktree (sidekick.nvim)

Travailler sur plusieurs branches en même temps, avec **un Claude dédié à chacune** :

- chaque **worktree** git s'ouvre dans **son propre onglet**, avec son dossier courant ;
- les raccourcis visent **toujours le Claude du dossier de l'onglet courant** ;
- les sessions tournent dans **tmux** : elles **survivent à la fermeture de Neovim**,
  `<leader>as` les reprend.

**Workflow type :**

1. `<leader>aW` → nom de branche → crée `<repo>.worktrees/<branche>`, l'ouvre dans un
   onglet et y lance Claude.
2. Donner la tâche, revenir à l'onglet principal (`gt` / `gT`) et continuer à travailler.
3. `<leader>aw` pour revenir sur un worktree (le courant est marqué `●`).
4. Une fois mergé : `<leader>ax` supprime le worktree (refusé s'il reste des
   modifications ; la branche est conservée).

| Raccourci    | Action                                             |
| ------------ | -------------------------------------------------- |
| `<leader>as` | Afficher/masquer le Claude du dossier courant      |
| `<leader>aS` | Choisir parmi toutes les sessions                  |
| `<leader>ad` | Détacher une session (elle continue dans tmux)     |
| `<leader>at` | Envoyer la position / sélection courante           |
| `<leader>af` | Envoyer le fichier                                 |
| `<leader>av` | Envoyer la sélection                               |
| `<leader>ai` | Prompts prédéfinis (expliquer, corriger, tester…)  |

---

## 10. Entretien de la config

- **Où** : branche `sans-lazyvim` du dépôt nvim-config, montée en worktree dans
  `~/dotfiles/neovimanu/.config/neovimanu` (`~/.config/neovimanu` y pointe).
- **Structure** : `init.lua` fixe l'ordre de chargement ; chaque `lua/manu/<module>.lua`
  ajoute ses plugins (`vim.pack.add`) puis les configure, avec en tête **pourquoi** chaque
  plugin est là.
- **Mettre à jour les plugins** : `:lua vim.pack.update()` ouvre un buffer de revue
  (`]]`/`[[` d'un plugin à l'autre, `K` pour le détail) ; `:write` applique, `:quit`
  annule. Puis lancer les tests et **commiter `nvim-pack-lock.json`**.
- **Revenir en arrière** : `git checkout HEAD -- nvim-pack-lock.json` puis
  `:lua vim.pack.update(nil, { target = "lockfile" })`.
- **Retirer un plugin** : enlever sa ligne de `vim.pack.add`, redémarrer, puis
  `:lua vim.pack.del({ "nom" })`.
- **Outils externes** (serveurs LSP, formateurs) : installés par Mason
  (`require("manu.mason").ensure({ … })` dans le fichier du langage), `<leader>cm` ouvre
  Mason.
- **Tests** :
  - `tests/run.sh` lance tous les tests headless (`tests/run.sh keymaps` pour un seul) ;
  - `tests/first_run.sh` réinstalle tout dans un dossier vide et vérifie le second
    démarrage (réseau, lent).
- **Règle des raccourcis** : un raccourci = **une déclaration** dans `lua/manu/*.lua`
  (avec une `desc`) **+ une ligne dans `KEYMAPS.md`**. `tests/run.sh keymaps` échoue si
  les deux divergent, ou si un plugin pose un raccourci global non déclaré (en le
  nommant). La liste blanche (mini.ai, flash, mini.pairs) est en tête du test.
- **Thème** : catppuccin mocha ou latte selon `~/.config/theme-mode` (`dark`/`light`).
  Après un changement de mode : `:lua require("manu.ui").apply_theme()`.

---

## 11. Ajouter un langage

Un langage = un fichier `lua/manu/lang/<langage>.lua`, requis à la fin de `init.lua`.
Modèle : `lua/manu/lang/lua.lua`, dans cet ordre :

```lua
-- 1. Plugins propres au langage (s'il y en a), avec la raison en commentaire
vim.pack.add({ "https://github.com/…" }, { confirm = false })

-- 2. Outils à installer par Mason
require("manu.mason").ensure({ "mon-serveur", "mon-formateur" })

-- 3. Surcharge de la config du serveur (ou fichier lsp/<serveur>.lua)
vim.lsp.config("mon_serveur", { settings = { … } })

-- 4. Activation
vim.lsp.enable({ "mon_serveur" })

-- 5. Formateur, seulement si le projet a sa config
local format = require("manu.format")
require("conform").formatters.mon_formateur = {
  condition = function(_, ctx)
    return format.project_has({ ".mon-formateur.toml" }, ctx.buf)
  end,
}
require("conform").formatters_by_ft.monft = { "mon_formateur" }

-- 6. Linter
require("lint").linters_by_ft.monft = { "mon_linter" }

-- 7. Parsers Treesitter
require("manu.treesitter").install({ "monft" })
```

Puis : raccourcis propres au langage dans une section `(buffer)` de `KEYMAPS.md`, un test
`tests/<langage>_spec.lua` (ouvrir une fixture avec `-- args:`), et une section ici.

---

## 12. Dépannage

| Symptôme                                   | À vérifier                                                     |
| ------------------------------------------ | -------------------------------------------------------------- |
| Un LSP ne démarre pas                      | `<leader>cl` (`:checkhealth vim.lsp`), puis `:Mason` : l'outil est-il installé ? |
| Rien ne se formate à l'enregistrement      | `:ConformInfo` ; le projet a-t-il la config du formateur ? `<leader>uf`/`<leader>uF` ont-ils coupé le formatage ? |
| Pas de diagnostics de lint                 | `:lua print(vim.inspect(require('lint').linters_by_ft))`, binaire dans le `PATH` |
| Pas de coloration                          | `:checkhealth nvim-treesitter` ; le parser est-il installé ? (`:TSInstall <langage>`) |
| Un plugin manque au démarrage              | `:lua vim.print(vim.pack.get())`, puis `tests/first_run.sh`    |
| Un raccourci a changé après une mise à jour | `tests/run.sh keymaps` nomme le plugin et la touche           |
| `<leader>od` : conteneurs du projet absents | Y a-t-il un `docker-compose.yml` à la racine ? Le démon Docker tourne-t-il ? |
| Les raccourcis Claude visent le mauvais agent | Vérifier le dossier de l'onglet : `:pwd`                    |
| Santé générale                             | `:checkhealth`                                                 |
