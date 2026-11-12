# Raccourcis de neovimanu

Règle : un raccourci = **une seule déclaration** dans `lua/manu/*.lua` (avec une `desc`)
**et une ligne ici**. `tests/run.sh keymaps` vérifie que les deux correspondent et qu'aucun
plugin ne pose de raccourci global non déclaré. Les sections dont le titre finit par
`(buffer)` listent des raccourcis propres à un buffer (LSP, Oil, filetype) : elles ne sont
pas comparées à la table globale.

Leader : `<Space>`. Localleader : `\`. Modes : `n` normal, `x` visuel, `o` opérateur,
`i` insertion, `t` terminal.

## Déplacements

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `j` | nx | Ligne suivante (affichée) | lua/manu/keymaps.lua |
| `<Down>` | nx | Ligne suivante (affichée) | lua/manu/keymaps.lua |
| `k` | nx | Ligne précédente (affichée) | lua/manu/keymaps.lua |
| `<Up>` | nx | Ligne précédente (affichée) | lua/manu/keymaps.lua |
| `n` | nxo | Résultat de recherche suivant | lua/manu/keymaps.lua |
| `N` | nxo | Résultat de recherche précédent | lua/manu/keymaps.lua |

## Fenêtres

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<C-h>` | n | Fenêtre de gauche | lua/manu/keymaps.lua |
| `<C-j>` | n | Fenêtre du dessous | lua/manu/keymaps.lua |
| `<C-k>` | n | Fenêtre du dessus | lua/manu/keymaps.lua |
| `<C-l>` | n | Fenêtre de droite | lua/manu/keymaps.lua |
| `<C-Up>` | n | Agrandir la hauteur | lua/manu/keymaps.lua |
| `<C-Down>` | n | Réduire la hauteur | lua/manu/keymaps.lua |
| `<C-Left>` | n | Réduire la largeur | lua/manu/keymaps.lua |
| `<C-Right>` | n | Agrandir la largeur | lua/manu/keymaps.lua |
| `<leader>-` | n | Découper en dessous | lua/manu/keymaps.lua |
| `<leader><Bar>` | n | Découper à droite | lua/manu/keymaps.lua |
| `<leader>wd` | n | Fermer la fenêtre | lua/manu/keymaps.lua |

## Buffers

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>bb` | n | Buffer alterné | lua/manu/keymaps.lua |
| ``<leader>` `` | n | Buffer alterné | lua/manu/keymaps.lua |
| `<leader>bd` | n | Fermer le buffer (garde la fenêtre) | lua/manu/keymaps.lua |
| `<leader>bo` | n | Fermer les autres buffers | lua/manu/keymaps.lua |
| `<leader>bi` | n | Fermer les buffers invisibles | lua/manu/keymaps.lua |
| `<leader>bD` | n | Fermer le buffer et la fenêtre | lua/manu/keymaps.lua |

## Onglets

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader><Tab><Tab>` | n | Nouvel onglet | lua/manu/keymaps.lua |
| `<leader><Tab>]` | n | Onglet suivant | lua/manu/keymaps.lua |
| `<leader><Tab>[` | n | Onglet précédent | lua/manu/keymaps.lua |
| `<leader><Tab>f` | n | Premier onglet | lua/manu/keymaps.lua |
| `<leader><Tab>l` | n | Dernier onglet | lua/manu/keymaps.lua |
| `<leader><Tab>d` | n | Fermer l'onglet | lua/manu/keymaps.lua |
| `<leader><Tab>o` | n | Fermer les autres onglets | lua/manu/keymaps.lua |

## Édition

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<Esc>` | ni | Échap et effacer la recherche (quitte aussi un snippet) | lua/manu/keymaps.lua |
| `<C-s>` | nxi | Enregistrer | lua/manu/keymaps.lua |
| `<A-j>` | nxi | Descendre la ligne / la sélection | lua/manu/keymaps.lua |
| `<A-k>` | nxi | Monter la ligne / la sélection | lua/manu/keymaps.lua |
| `,` | i | Virgule + point d'annulation | lua/manu/keymaps.lua |
| `.` | i | Point + point d'annulation | lua/manu/keymaps.lua |
| `;` | i | Point-virgule + point d'annulation | lua/manu/keymaps.lua |
| `<` | x | Désindenter (garder la sélection) | lua/manu/keymaps.lua |
| `>` | x | Indenter (garder la sélection) | lua/manu/keymaps.lua |
| `gco` | n | Commentaire en dessous | lua/manu/keymaps.lua |
| `gcO` | n | Commentaire au-dessus | lua/manu/keymaps.lua |
| `p` | x | Coller sans copier la sélection | lua/manu/keymaps.lua |
| `<CR>` | n | Ligne vide en dessous | lua/manu/keymaps.lua |
| `<S-CR>` | n | Ligne vide au-dessus | lua/manu/keymaps.lua |
| `<C-a>` | n | Tout sélectionner | lua/manu/keymaps.lua |
| `]s` | n | Faute d'orthographe suivante | lua/manu/keymaps.lua |
| `[s` | n | Faute d'orthographe précédente | lua/manu/keymaps.lua |
| `z=` | n | Suggestions d'orthographe | lua/manu/keymaps.lua |
| `zg` | n | Ajouter le mot au dictionnaire | lua/manu/keymaps.lua |
| `zw` | n | Marquer le mot comme faux | lua/manu/keymaps.lua |
| `zug` | n | Retirer le mot du dictionnaire | lua/manu/keymaps.lua |

## Fichiers

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>fn` | n | Nouveau fichier (demande le nom) | lua/manu/keymaps.lua |
| `<leader>yn` | n | Copier le nom du fichier | lua/manu/keymaps.lua |
| `<leader>yp` | n | Copier le chemin relatif | lua/manu/keymaps.lua |
| `<leader>yP` | n | Copier le chemin absolu | lua/manu/keymaps.lua |
| `<leader>qq` | n | Tout quitter | lua/manu/keymaps.lua |

## Interface / bascules

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>us` | n | Basculer l'orthographe | lua/manu/keymaps.lua |
| `<leader>uw` | n | Basculer le retour à la ligne | lua/manu/keymaps.lua |
| `<leader>uL` | n | Basculer les numéros relatifs | lua/manu/keymaps.lua |
| `<leader>ul` | n | Basculer les numéros de ligne | lua/manu/keymaps.lua |
| `<leader>uc` | n | Basculer le masquage (conceal) | lua/manu/keymaps.lua |
| `<leader>uA` | n | Basculer la barre d'onglets | lua/manu/keymaps.lua |
| `<leader>ud` | n | Basculer les diagnostics | lua/manu/keymaps.lua |
| `<leader>uT` | n | Basculer la coloration Treesitter | lua/manu/keymaps.lua |
| `<leader>ub` | n | Basculer fond sombre/clair | lua/manu/keymaps.lua |
| `<leader>ur` | n | Redessiner / effacer la recherche | lua/manu/keymaps.lua |
| `<leader>uI` | n | Arbre Treesitter | lua/manu/keymaps.lua |

## Documentation de la config

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>K` | n | Raccourcis (ce fichier, en flottant) | lua/manu/keymaps.lua |
| `<leader>M` | n | Manuel (flottant) | lua/manu/keymaps.lua |
| `<leader>H` | n | Manuel (navigateur, via mdview) | lua/manu/keymaps.lua |

## Fenêtres utilitaires (buffer)

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `q` | n | Fermer (aide, quickfix, man, checkhealth…) | lua/manu/autocmds.lua |
