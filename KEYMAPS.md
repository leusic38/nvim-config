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
| `<C-w><Space>` | n | Mode fenêtres (which-key, reste ouvert) | lua/manu/ui.lua |

## Buffers

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>,` | n | Changer de buffer (fzf) | lua/manu/picker.lua |
| `<leader>fb` | n | Buffers (fzf) | lua/manu/picker.lua |
| `<leader>fB` | n | Buffers, y compris non listés (fzf) | lua/manu/picker.lua |
| `<leader>bb` | n | Buffer alterné | lua/manu/keymaps.lua |
| ``<leader>` `` | n | Buffer alterné | lua/manu/keymaps.lua |
| `<leader>bd` | n | Fermer le buffer (garde la fenêtre) | lua/manu/keymaps.lua |
| `<leader>bo` | n | Fermer les autres buffers | lua/manu/keymaps.lua |
| `<leader>bi` | n | Fermer les buffers invisibles | lua/manu/keymaps.lua |
| `<leader>bD` | n | Fermer le buffer et la fenêtre | lua/manu/keymaps.lua |
| `<S-h>` | n | Buffer précédent | lua/manu/ui.lua |
| `<S-l>` | n | Buffer suivant | lua/manu/ui.lua |
| `[b` | n | Buffer précédent | lua/manu/ui.lua |
| `]b` | n | Buffer suivant | lua/manu/ui.lua |
| `[B` | n | Déplacer le buffer à gauche | lua/manu/ui.lua |
| `]B` | n | Déplacer le buffer à droite | lua/manu/ui.lua |
| `<leader>bp` | n | Épingler/désépingler le buffer | lua/manu/ui.lua |
| `<leader>bP` | n | Fermer les buffers non épinglés | lua/manu/ui.lua |
| `<leader>bl` | n | Fermer les buffers à gauche | lua/manu/ui.lua |
| `<leader>br` | n | Fermer les buffers à droite | lua/manu/ui.lua |
| `<leader>bj` | n | Choisir un buffer (lettre) | lua/manu/ui.lua |

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

## Diagnostics et listes

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>cd` | n | Diagnostics de la ligne | lua/manu/lsp.lua |
| `]d` | n | Diagnostic suivant | lua/manu/lsp.lua |
| `[d` | n | Diagnostic précédent | lua/manu/lsp.lua |
| `]e` | n | Erreur suivante | lua/manu/lsp.lua |
| `[e` | n | Erreur précédente | lua/manu/lsp.lua |
| `]w` | n | Avertissement suivant | lua/manu/lsp.lua |
| `[w` | n | Avertissement précédent | lua/manu/lsp.lua |
| `<leader>xl` | n | Liste locale (ouvrir/fermer) | lua/manu/lsp.lua |
| `<leader>xq` | n | Quickfix (ouvrir/fermer) | lua/manu/lsp.lua |
| `<leader>cm` | n | Mason | lua/manu/lsp.lua |
| `<leader>uh` | n | Basculer les indices inline (inlay hints) | lua/manu/lsp.lua |

## Formatage

Formatage à l'enregistrement seulement si le projet a la config du formateur.

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>cf` | nx | Formater (fichier ou sélection ; LSP si pas de formateur) | lua/manu/format.lua |
| `<leader>cF` | nx | Formater les langages injectés | lua/manu/format.lua |
| `<leader>uf` | n | Basculer le formatage auto (global) | lua/manu/format.lua |
| `<leader>uF` | n | Basculer le formatage auto (buffer) | lua/manu/format.lua |

## Fichiers

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader><Space>` | n | Fichiers (racine du projet) | lua/manu/picker.lua |
| `<leader>ff` | n | Fichiers (racine du projet) | lua/manu/picker.lua |
| `<leader>fF` | n | Fichiers (dossier courant) | lua/manu/picker.lua |
| `<leader>fg` | n | Fichiers suivis par git | lua/manu/picker.lua |
| `<leader>fr` | n | Fichiers récents | lua/manu/picker.lua |
| `<leader>fR` | n | Fichiers récents (dossier courant) | lua/manu/picker.lua |
| `<leader>fc` | n | Fichiers de la config Neovim | lua/manu/picker.lua |
| `-` | n | Dossier parent (Oil) | lua/manu/files.lua |
| `<leader>e` | n | Dossier parent (Oil flottant) | lua/manu/files.lua |
| `<leader>fn` | n | Nouveau fichier (demande le nom) | lua/manu/keymaps.lua |
| `<leader>yn` | n | Copier le nom du fichier | lua/manu/keymaps.lua |
| `<leader>yp` | n | Copier le chemin relatif | lua/manu/keymaps.lua |
| `<leader>yP` | n | Copier le chemin absolu | lua/manu/keymaps.lua |
| `<leader>qq` | n | Tout quitter | lua/manu/keymaps.lua |

## Recherche (fzf-lua)

« Racine » = premier parent contenant `.git`, `composer.json` ou `package.json`.

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>/` | n | Grep (racine du projet) | lua/manu/picker.lua |
| `<leader>sg` | n | Grep (racine du projet) | lua/manu/picker.lua |
| `<leader>sG` | n | Grep (dossier courant) | lua/manu/picker.lua |
| `<leader>sw` | nx | Mot sous le curseur / sélection (racine) | lua/manu/picker.lua |
| `<leader>sW` | nx | Mot sous le curseur / sélection (dossier courant) | lua/manu/picker.lua |
| `<leader>sb` | n | Lignes du buffer | lua/manu/picker.lua |
| `<leader>:` | n | Historique des commandes | lua/manu/picker.lua |
| `<leader>sc` | n | Historique des commandes | lua/manu/picker.lua |
| `<leader>s/` | n | Historique des recherches | lua/manu/picker.lua |
| `<leader>s"` | n | Registres | lua/manu/picker.lua |
| `<leader>sC` | n | Commandes | lua/manu/picker.lua |
| `<leader>sa` | n | Autocommandes | lua/manu/picker.lua |
| `<leader>sh` | n | Pages d'aide | lua/manu/picker.lua |
| `<leader>sH` | n | Groupes de surlignage | lua/manu/picker.lua |
| `<leader>sM` | n | Pages man | lua/manu/picker.lua |
| `<leader>sk` | n | Raccourcis | lua/manu/picker.lua |
| `<leader>sj` | n | Liste des sauts | lua/manu/picker.lua |
| `<leader>sm` | n | Marques | lua/manu/picker.lua |
| `<leader>sl` | n | Liste locale | lua/manu/picker.lua |
| `<leader>sq` | n | Quickfix | lua/manu/picker.lua |
| `<leader>sR` | n | Reprendre la dernière recherche | lua/manu/picker.lua |
| `<leader>sd` | n | Diagnostics (projet) | lua/manu/picker.lua |
| `<leader>sD` | n | Diagnostics (buffer) | lua/manu/picker.lua |
| `<leader>ss` | n | Symboles du fichier (LSP) | lua/manu/picker.lua |
| `<leader>sS` | n | Symboles du projet (LSP) | lua/manu/picker.lua |
| `<leader>uC` | n | Thèmes (aperçu) | lua/manu/picker.lua |

## Terminal

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<C-Bslash>` | nt | Terminal flottant (ouvrir/cacher) | lua/manu/terminal.lua |
| `<leader>tf` | n | Terminal flottant | lua/manu/terminal.lua |
| `<leader>th` | n | Terminal horizontal | lua/manu/terminal.lua |
| `<leader>tv` | n | Terminal vertical | lua/manu/terminal.lua |
| `<leader>ft` | n | Terminal (racine du projet) | lua/manu/terminal.lua |
| `<leader>fT` | n | Terminal (dossier courant) | lua/manu/terminal.lua |
| `<C-/>` | nt | Terminal (racine du projet) | lua/manu/terminal.lua |
| `<C-_>` | nt | Terminal (racine du projet), variante de `<C-/>` | lua/manu/terminal.lua |
| `<leader>od` | n | Lazydocker (conteneurs) | lua/manu/terminal.lua |

## Git

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>gg` | n | Lazygit (racine du projet) | lua/manu/terminal.lua |
| `<leader>gG` | n | Lazygit (dossier courant) | lua/manu/terminal.lua |
| `<leader>gd` | n | Diffview (HEAD) | lua/manu/git.lua |
| `<leader>gD` | n | Fermer Diffview | lua/manu/git.lua |
| `<leader>gF` | n | Historique du fichier (Diffview) | lua/manu/git.lua |
| `<leader>gs` | n | Statut git (fzf) | lua/manu/git.lua |
| `<leader>gS` | n | Stash git (fzf) | lua/manu/git.lua |
| `<leader>gc` | n | Commits (fzf) | lua/manu/git.lua |
| `<leader>gl` | n | Commits (racine du projet) | lua/manu/git.lua |
| `<leader>gL` | n | Commits (dossier courant) | lua/manu/git.lua |
| `<leader>gf` | n | Historique du fichier (fzf) | lua/manu/git.lua |
| `<leader>gb` | n | Blame de la ligne | lua/manu/git.lua |

## Édition (plugins)

Posés par les plugins eux-mêmes (autorisés par le test) : `f` `t` `F` `T` `;` `,` (flash,
sauts sur plusieurs lignes), objets `a…`/`i…` et `g[`/`g]` (mini.ai : `af`/`if` fonction,
`ac` classe, `ao` bloc, `at` balise, `ad` nombre, `ae` mot, `ag` buffer, `au` appel,
`aa` argument, `an…`/`al…` suivant/précédent), paires en insertion (mini.pairs).
En recherche (`/`), `<C-s>` bascule les étiquettes flash.

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `s` | nxo | Flash : sauter | lua/manu/editing.lua |
| `S` | nxo | Flash : nœud Treesitter | lua/manu/editing.lua |
| `r` | o | Flash à distance | lua/manu/editing.lua |
| `R` | xo | Flash : recherche Treesitter | lua/manu/editing.lua |
| `<C-Space>` | nxo | Sélection incrémentale (Treesitter ; `<C-Space>` étend, `<BS>` réduit) | lua/manu/editing.lua |
| `<leader>sr` | nx | Rechercher et remplacer dans le projet (grug-far) | lua/manu/editing.lua |
| `]t` | n | TODO suivant | lua/manu/editing.lua |
| `[t` | n | TODO précédent | lua/manu/editing.lua |
| `<leader>st` | n | TODO (fzf) | lua/manu/editing.lua |
| `<leader>sT` | n | TODO/FIX/FIXME (fzf) | lua/manu/editing.lua |
| `<leader>Rm` | nx | Refactoring : menu | lua/manu/editing.lua |
| `<leader>Re` | x | Refactoring : extraire une fonction | lua/manu/editing.lua |
| `<leader>Rf` | x | Refactoring : extraire une fonction dans un fichier | lua/manu/editing.lua |
| `<leader>Rv` | x | Refactoring : extraire une variable | lua/manu/editing.lua |
| `<leader>Ri` | nx | Refactoring : inliner la variable | lua/manu/editing.lua |
| `<leader>up` | n | Basculer la fermeture auto des paires | lua/manu/editing.lua |

## Trouble

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>xx` | n | Diagnostics (Trouble) | lua/manu/editing.lua |
| `<leader>xX` | n | Diagnostics du buffer (Trouble) | lua/manu/editing.lua |
| `<leader>cs` | n | Symboles (Trouble) | lua/manu/editing.lua |
| `<leader>cS` | n | Références/définitions LSP (Trouble) | lua/manu/editing.lua |
| `<leader>xL` | n | Liste locale (Trouble) | lua/manu/editing.lua |
| `<leader>xQ` | n | Quickfix (Trouble) | lua/manu/editing.lua |
| `<leader>xt` | n | TODO (Trouble) | lua/manu/editing.lua |
| `<leader>xT` | n | TODO/FIX/FIXME (Trouble) | lua/manu/editing.lua |
| `[q` | n | Élément précédent (Trouble s'il est ouvert, sinon quickfix) | lua/manu/editing.lua |
| `]q` | n | Élément suivant (Trouble s'il est ouvert, sinon quickfix) | lua/manu/editing.lua |

## Sessions

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>qs` | n | Restaurer la session (dossier) | lua/manu/editing.lua |
| `<leader>qS` | n | Choisir une session | lua/manu/editing.lua |
| `<leader>ql` | n | Restaurer la dernière session | lua/manu/editing.lua |
| `<leader>qd` | n | Ne pas enregistrer la session | lua/manu/editing.lua |

## IA (Claude)

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<leader>as` | n | Claude (sidekick) du worktree : afficher/masquer | lua/manu/ai.lua |
| `<leader>aS` | n | Sidekick : choisir une session | lua/manu/ai.lua |
| `<leader>ad` | n | Sidekick : détacher une session | lua/manu/ai.lua |
| `<leader>at` | nx | Claude : envoyer ceci | lua/manu/ai.lua |
| `<leader>af` | n | Claude : envoyer le fichier | lua/manu/ai.lua |
| `<leader>av` | x | Claude : envoyer la sélection | lua/manu/ai.lua |
| `<leader>ai` | nx | Claude : prompts | lua/manu/ai.lua |
| `<leader>aw` | n | Worktree : changer | lua/manu/ai.lua |
| `<leader>aW` | n | Worktree : créer + Claude | lua/manu/ai.lua |
| `<leader>ax` | n | Worktree : supprimer | lua/manu/ai.lua |
| `<leader>aa` | n | Claude dans un onglet terminal | lua/manu/ai.lua |
| `<leader>aq` | x | Envoyer la sélection à Claude (onglet) | lua/manu/ai.lua |
| `<leader>ap` | nx | Claude expert (stacks détectées) | lua/manu/ai.lua |
| `<leader>aep` | nx | Claude expert PHP/Symfony | lua/manu/ai.lua |
| `<leader>aej` | nx | Claude expert JS/TS/Vue.js | lua/manu/ai.lua |
| `<leader>aek` | nx | Claude expert Kotlin | lua/manu/ai.lua |
| `<leader>aet` | nx | Claude expert Terraform | lua/manu/ai.lua |
| `<leader>ar` | n | Revue de code par Claude | lua/manu/ai.lua |
| `<leader>yc` | nx | Copier pour Claude (chemin + lignes) | lua/manu/ai.lua |

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
| `<leader>?` | n | Raccourcis du buffer (which-key) | lua/manu/ui.lua |

## Code / LSP (buffer)

Posés à l'attache d'un serveur (LspAttach). S'ajoutent aux touches natives de Neovim :
`grn` renommer, `gra` actions, `grr` références, `gri` implémentation, `grt` type,
`gO` symboles du document, `<C-s>` (insertion) signature.

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `gd` | n | Aller à la définition (sauf si le buffer a déjà son `gd`) | lua/manu/lsp.lua |
| `gr` | n | Références | lua/manu/lsp.lua |
| `gI` | n | Aller à l'implémentation | lua/manu/lsp.lua |
| `gy` | n | Aller au type | lua/manu/lsp.lua |
| `gD` | n | Aller à la déclaration | lua/manu/lsp.lua |
| `K` | n | Documentation (survol) | lua/manu/lsp.lua |
| `gK` | n | Signature | lua/manu/lsp.lua |
| `<C-k>` | i | Signature | lua/manu/lsp.lua |
| `<leader>ca` | nx | Actions de code | lua/manu/lsp.lua |
| `<leader>cA` | n | Actions sur le fichier (source) | lua/manu/lsp.lua |
| `<leader>co` | n | Organiser les imports | lua/manu/lsp.lua |
| `<leader>cr` | n | Renommer le symbole | lua/manu/lsp.lua |
| `<leader>cR` | n | Renommer le fichier (prévient le serveur) | lua/manu/lsp.lua |
| `<leader>cc` | nx | Lancer le codelens | lua/manu/lsp.lua |
| `<leader>cC` | n | Afficher les codelens | lua/manu/lsp.lua |
| `<leader>cl` | n | Infos LSP (`:checkhealth vim.lsp`) | lua/manu/lsp.lua |
| `]]` / `<M-n>` | n | Référence suivante du symbole | lua/manu/lsp.lua |
| `[[` / `<M-p>` | n | Référence précédente du symbole | lua/manu/lsp.lua |

## Treesitter (buffer)

Posés quand le langage a des requêtes textobjects.

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `]f` / `[f` | nxo | Début de fonction suivante / précédente | lua/manu/treesitter.lua |
| `]F` / `[F` | nxo | Fin de fonction suivante / précédente | lua/manu/treesitter.lua |
| `]c` / `[c` | nxo | Début de classe suivante / précédente (hors mode diff) | lua/manu/treesitter.lua |
| `]C` / `[C` | nxo | Fin de classe suivante / précédente | lua/manu/treesitter.lua |
| `]a` / `[a` | nxo | Début de paramètre suivant / précédent | lua/manu/treesitter.lua |
| `]A` / `[A` | nxo | Fin de paramètre suivant / précédent | lua/manu/treesitter.lua |

## Complétion (buffer, blink.cmp)

Préréglage `enter` : `<CR>` accepte, `<C-Space>` ouvre le menu ou la doc, `<C-n>`/`<C-p>`
ou `<Up>`/`<Down>` naviguent, `<C-e>` ferme, `<Tab>`/`<S-Tab>` sautent dans un snippet,
`<C-b>`/`<C-f>` font défiler la doc, `<C-k>` affiche la signature.

## Oil (buffer)

Dans un dossier ouvert par Oil (`g?` affiche toutes les touches) : `<CR>` ouvrir,
`-` dossier parent, `_` dossier courant de Neovim, `<C-s>` découpage vertical,
`<C-t>` onglet, `<C-p>` aperçu, `<C-l>` rafraîchir, `g.` fichiers cachés, `gs` tri,
`gx` ouvrir avec le système, `` ` `` / `~` changer de dossier courant. `:w` applique les
modifications (renommer, créer, supprimer).

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<A-v>` | n | Ouvrir dans un découpage vertical | lua/manu/files.lua |
| `<A-h>` | n | Ouvrir dans un découpage horizontal | lua/manu/files.lua |

## Terminal toggleterm (buffer)

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `<Esc>` | t | Fermer le terminal (pas dans lazygit/lazydocker) | lua/manu/terminal.lua |
| `<C-Space>` | t | Mode normal sans fermer | lua/manu/terminal.lua |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | t | Aller à la fenêtre voisine | lua/manu/terminal.lua |

## Git (buffer)

Posés par gitsigns dans un fichier suivi.

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `]h` / `[h` | n | Hunk suivant / précédent (`]c`/`[c` en mode diff) | lua/manu/git.lua |
| `]H` / `[H` | n | Dernier / premier hunk | lua/manu/git.lua |
| `<leader>ghs` | nx | Indexer le hunk | lua/manu/git.lua |
| `<leader>ghr` | nx | Annuler le hunk | lua/manu/git.lua |
| `<leader>ghS` | n | Indexer le fichier | lua/manu/git.lua |
| `<leader>ghu` | n | Désindexer le hunk | lua/manu/git.lua |
| `<leader>ghR` | n | Annuler les modifications du fichier | lua/manu/git.lua |
| `<leader>ghp` | n | Aperçu du hunk | lua/manu/git.lua |
| `<leader>ghb` | n | Blame de la ligne | lua/manu/git.lua |
| `<leader>ghB` | n | Blame du fichier | lua/manu/git.lua |
| `<leader>ghd` | n | Diff du fichier | lua/manu/git.lua |
| `<leader>ghD` | n | Diff du fichier (~) | lua/manu/git.lua |
| `ih` | ox | Hunk (objet textuel) | lua/manu/git.lua |
| `<leader>gc` | n | Message de commit : type Conventional Commits | lua/manu/git.lua |

## Diffview, conflit de fusion (buffer)

Touches de diffview.nvim dans le fichier central d'un conflit (elles masquent `<leader>ca`
et `<leader>co` du LSP dans ce buffer).

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `]x` / `[x` | n | Conflit suivant / précédent | (diffview) |
| `<leader>co` / `<leader>cO` | n | Garder ours (bloc / fichier) | (diffview) |
| `<leader>ct` / `<leader>cT` | n | Garder theirs (bloc / fichier) | (diffview) |
| `<leader>cb` / `<leader>cB` | n | Garder la base (bloc / fichier) | (diffview) |
| `<leader>ca` / `<leader>cA` | n | Garder les deux (bloc / fichier) | (diffview) |
| `dx` | n | Supprimer le bloc de conflit | (diffview) |

## Page d'accueil (buffer)

Affichée par `nn` seul ou `nn <dossier>` (Neovim se place alors dans le dossier) ;
`:Accueil` la rouvre. `<CR>` lance l'élément sous le curseur.

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `f` | n | Trouver un fichier | lua/manu/dashboard.lua |
| `r` | n | Fichiers récents du projet | lua/manu/dashboard.lua |
| `g` | n | Chercher du texte | lua/manu/dashboard.lua |
| `s` | n | Restaurer la session | lua/manu/dashboard.lua |
| `e` | n | Explorer le dossier (Oil) | lua/manu/dashboard.lua |
| `n` | n | Nouveau fichier | lua/manu/dashboard.lua |
| `G` | n | Lazygit | lua/manu/dashboard.lua |
| `a` | n | Claude (sidekick) | lua/manu/dashboard.lua |
| `c` | n | Config Neovim | lua/manu/dashboard.lua |
| `m` | n | Manuel | lua/manu/dashboard.lua |
| `q` | n | Quitter | lua/manu/dashboard.lua |
| `1` … `5` | n | Ouvrir un fichier récent du dossier | lua/manu/dashboard.lua |
| `<CR>` | n | Lancer l'élément sous le curseur | lua/manu/dashboard.lua |

## Fenêtres utilitaires (buffer)

| Touche | Mode | Action | Fichier |
|--------|------|--------|---------|
| `q` | n | Fermer (aide, quickfix, man, checkhealth…) | lua/manu/autocmds.lua |
