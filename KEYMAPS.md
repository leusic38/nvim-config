# 🚀 Guide Complet des Raccourcis Neovim - Configuration Manu

> **Leader Key**: `<space>` (espace)  
> **Découverte**: Pressez `<leader>` et attendez pour voir les raccourcis disponibles  
> **Aide**: `<leader>sk` pour chercher dans tous les raccourcis

---

## 📁 Navigation & Fichiers

### Gestion des Fichiers

| Raccourci         | Action                     | Description                            |
| ----------------- | -------------------------- | -------------------------------------- |
| `<leader><space>` | **Trouver fichiers**       | Recherche de fichiers (dossier racine) |
| `<leader>ff`      | **Trouver fichiers**       | Recherche de fichiers (dossier racine) |
| `<leader>fF`      | **Trouver fichiers (cwd)** | Recherche dans le dossier courant      |
| `<leader>fg`      | **Fichiers Git**           | Fichiers suivis par Git                |
| `<leader>fr`      | **Fichiers récents**       | Fichiers récemment ouverts             |
| `<leader>fc`      | **Config files**           | Fichiers de configuration              |
| `<leader>fn`      | **Nouveau fichier**        | Créer un nouveau fichier avec invite   |

### Explorateur de Fichiers (Oil.nvim)

| Raccourci   | Action                    | Description                           |
| ----------- | ------------------------- | ------------------------------------- |
| `-`         | **Ouvrir dossier parent** | Navigation Oil dans fenêtre courante  |
| `<leader>e` | **Oil flottant**          | Explorateur flottant (custom)         |
| `<Alt-v>`   | **Split vertical**        | Ouvrir en split vertical (dans Oil)   |
| `<Alt-h>`   | **Split horizontal**      | Ouvrir en split horizontal (dans Oil) |

---

## 🔍 Recherche & Navigation

### Recherche Globale (Telescope)

| Raccourci    | Action                   | Description                            |
| ------------ | ------------------------ | -------------------------------------- |
| `<leader>/`  | **Recherche grep**       | Recherche dans tous les fichiers       |
| `<leader>sw` | **Chercher mot**         | Chercher le mot sous le curseur        |
| `<leader>sW` | **Chercher mot (cwd)**   | Chercher dans le dossier courant       |
| `<leader>sr` | **Recherche & remplace** | Interface recherche/remplacement       |
| `<leader>ss` | **Symboles**             | Naviguer vers les symboles             |
| `<leader>sS` | **Symboles workspace**   | Symboles dans tout l'espace de travail |
| `<leader>sh` | **Pages d'aide**         | Documentation Neovim                   |
| `<leader>sk` | **Raccourcis clavier**   | Chercher dans les keymaps              |
| `<leader>sm` | **Marques**              | Aller aux marques                      |

### Navigation LSP (Code)

| Raccourci | Action                 | Description              |
| --------- | ---------------------- | ------------------------ |
| `gd`      | **Aller à définition** | Définition du symbole    |
| `gr`      | **Références**         | Toutes les références    |
| `gI`      | **Implémentation**     | Aller à l'implémentation |
| `gy`      | **Type définition**    | Définition du type       |
| `K`       | **Documentation**      | Hover documentation      |

---

## 📝 Édition & Code

### Actions de Code (LSP)

| Raccourci    | Action                | Description                  |
| ------------ | --------------------- | ---------------------------- |
| `<leader>ca` | **Actions de code**   | Menu d'actions rapides       |
| `<leader>cr` | **Renommer**          | Renommer le symbole          |
| `<leader>cf` | **Formater**          | Formatter le code            |
| `<leader>cd` | **Diagnostics ligne** | Voir les erreurs de la ligne |

### Édition Avancée (Custom)

| Raccourci       | Action                | Description                       |
| --------------- | --------------------- | --------------------------------- |
| `<Ctrl-a>`      | **Tout sélectionner** | Sélection complète du fichier     |
| `<Enter>`       | **Nouvelle ligne**    | Ajouter ligne en dessous          |
| `<Shift-Enter>` | **Ligne au-dessus**   | Ajouter ligne au-dessus           |
| `v` puis `p`    | **Coller sans yank**  | Coller sans remplacer le registre |

### Déplacement de Texte

| Raccourci     | Action              | Description                             |
| ------------- | ------------------- | --------------------------------------- |
| `<Alt-j>`     | **Ligne vers bas**  | Déplacer ligne(s) vers le bas           |
| `<Alt-k>`     | **Ligne vers haut** | Déplacer ligne(s) vers le haut          |
| `<` / `>`     | **Indentation**     | Diminuer/augmenter indentation (Visual) |
| `gco` / `gcO` | **Commentaire**     | Ajouter commentaire sous/au-dessus      |

---

## 🪟 Fenêtres & Buffers

### Navigation Fenêtres

| Raccourci  | Action             | Description             |
| ---------- | ------------------ | ----------------------- |
| `<Ctrl-h>` | **Fenêtre gauche** | Naviguer vers la gauche |
| `<Ctrl-j>` | **Fenêtre bas**    | Naviguer vers le bas    |
| `<Ctrl-k>` | **Fenêtre haut**   | Naviguer vers le haut   |
| `<Ctrl-l>` | **Fenêtre droite** | Naviguer vers la droite |

### Gestion Fenêtres

| Raccourci    | Action               | Description                   |
| ------------ | -------------------- | ----------------------------- |
| `<leader>-`  | **Split horizontal** | Diviser horizontalement       |
| `<leader>\|` | **Split vertical**   | Diviser verticalement         |
| `<leader>wd` | **Fermer fenêtre**   | Supprimer la fenêtre courante |
| `<leader>wm` | **Toggle zoom**      | Basculer le mode zoom         |

### Gestion Buffers

| Raccourci    | Action               | Description                    |
| ------------ | -------------------- | ------------------------------ |
| `<Shift-h>`  | **Buffer précédent** | Buffer précédent               |
| `<Shift-l>`  | **Buffer suivant**   | Buffer suivant                 |
| `<leader>bb` | **Changer buffer**   | Basculer entre buffers         |
| `<leader>,`  | **Liste buffers**    | Choisir buffer (Telescope)     |
| `<leader>bd` | **Fermer buffer**    | Supprimer le buffer courant    |
| `<leader>bo` | **Fermer autres**    | Fermer tous les autres buffers |

---

## 🐛 Debug & Diagnostics

### Debugging (DAP + PHP Custom)

| Raccourci     | Action                       | Description                                 |
| ------------- | ---------------------------- | ------------------------------------------- |
| `<leader>pdb` | **Toggle breakpoint**        | Breakpoint persistant (survit au redémarrage) |
| `<leader>pdB` | **Breakpoint conditionnel**  | Breakpoint avec condition d'arrêt           |
| `<leader>pdc` | **Continue**                 | Continuer l'exécution                       |
| `<leader>pds` | **Step over**                | Passer au-dessus                            |
| `<leader>pdi` | **Step into**                | Entrer dans la fonction                     |
| `<leader>pdo` | **Step out**                 | Sortir de la fonction                       |
| `<leader>pdr` | **REPL**                     | Ouvrir la console debug                     |
| `<leader>pdt` | **Terminer**                 | Arrêter le debug                            |
| `<leader>du`  | **UI compact**               | Scopes + Breakpoints (panneau droit)        |
| `<leader>dU`  | **UI complet**               | Scopes + Stacks + Watches + Console         |

### Diagnostics & Erreurs

| Raccourci    | Action                           | Description                     |
| ------------ | -------------------------------- | ------------------------------- |
| `]d` / `[d`  | **Diagnostic suivant/précédent** | Navigation dans les erreurs     |
| `]e` / `[e`  | **Erreur suivante/précédente**   | Navigation erreurs uniquement   |
| `]w` / `[w`  | **Warning suivant/précédent**    | Navigation avertissements       |
| `<leader>xx` | **Liste diagnostics**            | Tous les diagnostics (Trouble)  |
| `<leader>xX` | **Diagnostics buffer**           | Diagnostics du buffer (Trouble) |
| `<leader>xl` | **Location list**                | Liste des emplacements          |
| `<leader>xq` | **Quickfix**                     | Liste quickfix                  |

---

## 🧪 Tests (PHP Custom)

### PHPUnit Integration

| Raccourci    | Action                  | Description                      |
| ------------ | ----------------------- | -------------------------------- |
| `<leader>ta` | **Tests du fichier**    | Lancer tous les tests du fichier |
| `<leader>tn` | **Test le plus proche** | Test sous le curseur             |
| `<leader>ts` | **Résumé tests**        | Basculer panneau résumé          |
| `<leader>to` | **Sortie test**         | Voir la sortie des tests         |

---

## 🛠️ PHP Développement (Custom)

### Outils PHP

| Raccourci    | Action              | Description                 |
| ------------ | ------------------- | --------------------------- |
| `<leader>lf` | **Format LSP**      | Formatter avec LSP          |
| `<leader>lc` | **Format CS Fixer** | Formatter avec PHP CS Fixer |
| `<leader>ll` | **PHPStan**         | Lancer analyse statique     |

### PHPActor (Refactoring)

| Raccourci    | Action              | Description          |
| ------------ | ------------------- | -------------------- |
| `<leader>pm` | **Menu PHPActor**   | Menu contextuel      |
| `<leader>pn` | **Nouvelle classe** | Créer une classe     |
| `<leader>pE` | **Expand classe**   | Développer la classe |
| `<leader>pT` | **Transform**       | Transformer le code  |
| `<leader>pi` | **Import classe**   | Importer une classe  |

### Snippets PHP Rapides

| Raccourci    | Action                  | Description                |
| ------------ | ----------------------- | -------------------------- |
| `<leader>pv` | **Header PHP**          | `<?php` + strict_types     |
| `<leader>pc` | **Classe template**     | Template de classe         |
| `<leader>pf` | **Fonction template**   | Template de fonction       |
| `<leader>pe` | **Entity template**     | Template d'entité Doctrine |
| `<leader>pr` | **Repository template** | Template de repository     |
| `<leader>ps` | **Service template**    | Template de service        |

### Symfony Console

> Majuscule `<S>` pour éviter les conflits avec les defaults LazyVim (`<leader>sr`, `<leader>ss`)

| Raccourci    | Action               | Description               |
| ------------ | -------------------- | ------------------------- |
| `<leader>Sc` | **Console command**  | Lancer commande console   |
| `<leader>Sm` | **Make command**     | Commande make             |
| `<leader>Sd` | **Doctrine command** | Commande doctrine         |
| `<leader>Sr` | **Debug routes**     | Afficher les routes       |
| `<leader>Ss` | **Debug services**   | Afficher les services     |
| `<leader>Se` | **Debug config**     | Afficher la configuration |

### Composer

> Majuscule `<C>` pour éviter les conflits avec les defaults LazyVim (`<leader>cr` = Rename, `<leader>cd` = Diagnostics)

| Raccourci    | Action               | Description                  |
| ------------ | -------------------- | ---------------------------- |
| `<leader>Cu` | **Composer update**  | Mise à jour des dépendances  |
| `<leader>Ci` | **Composer install** | Installation des dépendances |
| `<leader>Cd` | **Dump autoload**    | Régénérer l'autoload         |
| `<leader>Cr` | **Composer require** | Ajouter une dépendance       |

---

## 🔁 Refactoring (refactoring.nvim)

> Fonctionne pour PHP, JS/TS, Lua et autres langages supportés par Treesitter

| Raccourci     | Action                      | Description                               | Mode   |
| ------------- | --------------------------- | ----------------------------------------- | ------ |
| `<leader>Rm`  | **Menu refactoring**        | Menu interactif de refactoring            | n / v  |
| `<leader>Re`  | **Extract function**        | Extraire la sélection en fonction         | v      |
| `<leader>Rf`  | **Extract to file**         | Extraire la sélection dans un nouveau fichier | v  |
| `<leader>Rv`  | **Extract variable**        | Extraire la sélection en variable         | v      |
| `<leader>Ri`  | **Inline variable**         | Inliner la variable sous le curseur       | n / v  |
| `<leader>Rb`  | **Extract block**           | Extraire le bloc en fonction              | v      |
| `<leader>RF`  | **Extract block to file**   | Extraire le bloc dans un nouveau fichier  | v      |
| `<leader>RT`  | **Telescope refactors**     | Parcourir les refactorings via Telescope  | n / v  |

---

## 🌐 REST Client (kulala.nvim)

> S'active uniquement pour les fichiers `.http`

| Raccourci    | Action                  | Description                                  |
| ------------ | ----------------------- | -------------------------------------------- |
| `<leader>rs` | **Envoyer requête**     | Exécuter la requête HTTP sous le curseur     |
| `<leader>rr` | **Rejouer**             | Rejouer la dernière requête                  |
| `<leader>rc` | **Copier cURL**         | Copier la requête au format cURL             |
| `<leader>re` | **Changer env**         | Switcher entre environnements (local/staging/prod) |
| `<leader>rb` | **Scratchpad**          | Ouvrir un scratchpad de requêtes temporaires |

**Config par projet** : créer `.nvim/kulala.lua` avec `{ default_env = "staging" }` pour surcharger l'env par défaut.

---

## 🗄️ Base de données (vim-dadbod)

| Raccourci    | Action                  | Description                           |
| ------------ | ----------------------- | ------------------------------------- |
| `<leader>Du` | **Toggle DB UI**        | Ouvrir/fermer l'interface DB          |
| `<leader>Da` | **Ajouter connexion**   | Ajouter une connexion à la DB         |
| `<leader>Df` | **Trouver buffer**      | Trouver un buffer SQL lié à la DB     |

**Config par projet** : créer `.nvim/dadbod.lua` pour les connexions du projet :
```lua
return { dbs = { { name = "local", url = "mysql://root:@127.0.0.1/mydb" } } }
```

---

## 🤖 Intelligence Artificielle (Claude)

### Chat & Actions

| Raccourci    | Action                | Description                            |
| ------------ | --------------------- | -------------------------------------- |
| `<leader>aa`  | **Ouvrir Claude**     | Ouvrir Claude dans un terminal                       |
| `<leader>aq`  | **Envoyer sélection** | Envoyer la sélection à Claude (Visual)               |
| `<leader>ap`  | **Expert auto**       | Détecte tous les stacks du projet, lance depuis sa racine (lit le CLAUDE.md) |
| `<leader>aep` | **Expert PHP**        | Force l'expert PHP/Symfony                           |
| `<leader>aej` | **Expert JS/TS/Vue**  | Force l'expert JS/TS/Vue.js                          |
| `<leader>aek` | **Expert Kotlin**     | Force l'expert Kotlin                                |
| `<leader>aet` | **Expert Terraform**  | Force l'expert Terraform                             |
| `<leader>ar`  | **Code Review**       | Révision de code avec Claude                         |

### Utilitaires IA

| Raccourci    | Action               | Description                              |
| ------------ | -------------------- | ---------------------------------------- |
| `<leader>yc` | **Yank pour Claude** | Copier au format Claude (`@file#L10-20`) |
| `<leader>yn` | **Copier nom**       | Copier le nom du fichier courant (`ai.lua`) dans le presse-papier |
| `<leader>yp` | **Copier chemin rel.** | Copier le chemin relatif (`lua/plugins/ai.lua`) |
| `<leader>yP` | **Copier chemin abs.** | Copier le chemin absolu (`/home/.../ai.lua`) |

---

## 💻 Développement JavaScript/TypeScript

### Tests JavaScript

| Raccourci    | Action               | Description                      |
| ------------ | -------------------- | -------------------------------- |
| `<leader>ta` | **Tests fichier JS** | Lancer tous les tests du fichier |
| `<leader>tn` | **Test proche JS**   | Test le plus proche du curseur   |
| `<leader>ts` | **Résumé tests JS**  | Basculer panneau résumé          |
| `<leader>to` | **Sortie test JS**   | Voir la sortie des tests         |
| `<leader>tw` | **Watch tests**      | Surveiller les tests             |

### TypeScript Tools

| Raccourci    | Action                | Description                  |
| ------------ | --------------------- | ---------------------------- |
| `<leader>lo` | **Organiser imports** | Organiser les imports        |
| `<leader>ls` | **Trier imports**     | Trier les imports            |
| `<leader>lu` | **Supprimer imports** | Supprimer imports inutiles   |
| `<leader>la` | **Ajouter imports**   | Ajouter imports manquants    |
| `<leader>lf` | **Corriger tout**     | Corriger tous les problèmes  |
| `<leader>lr` | **Renommer fichier**  | Renommer le fichier          |
| `<leader>lg` | **Définition source** | Aller à la définition source |
| `<leader>le` | **ESLint fix**        | Corriger avec ESLint         |

### Package Management

| Raccourci    | Action              | Description             |
| ------------ | ------------------- | ----------------------- |
| `<leader>ns` | **Info package**    | Afficher info package   |
| `<leader>nc` | **Cacher info**     | Masquer info package    |
| `<leader>nt` | **Toggle info**     | Basculer info package   |
| `<leader>nu` | **Update package**  | Mettre à jour package   |
| `<leader>nd` | **Delete package**  | Supprimer package       |
| `<leader>ni` | **Install package** | Installer package       |
| `<leader>np` | **Changer version** | Changer version package |

### NPM Commands

| Raccourci    | Action          | Description                  |
| ------------ | --------------- | ---------------------------- |
| `<leader>ni` | **npm install** | Installation des dépendances |
| `<leader>nr` | **npm run**     | Lancer script npm            |
| `<leader>nt` | **npm test**    | Lancer les tests             |
| `<leader>nb` | **npm build**   | Construire le projet         |
| `<leader>nd` | **npm dev**     | Mode développement           |

### Yarn Commands

| Raccourci    | Action           | Description            |
| ------------ | ---------------- | ---------------------- |
| `<leader>yi` | **yarn install** | Installation avec Yarn |
| `<leader>yr` | **yarn run**     | Lancer script Yarn     |
| `<leader>yt` | **yarn test**    | Tests avec Yarn        |
| `<leader>yb` | **yarn build**   | Build avec Yarn        |
| `<leader>yd` | **yarn dev**     | Dev avec Yarn          |

### Snippets JavaScript/TypeScript

| Raccourci    | Action             | Description                   |
| ------------ | ------------------ | ----------------------------- |
| `<leader>jc` | **Composant JS**   | Template composant JavaScript |
| `<leader>jf` | **Fonction JS**    | Template fonction JavaScript  |
| `<leader>ja` | **Fonction async** | Template fonction async       |
| `<leader>tc` | **Classe TS**      | Template classe TypeScript    |
| `<leader>ti` | **Interface TS**   | Template interface TypeScript |

### Vue.js Development

| Raccourci    | Action             | Description                    |
| ------------ | ------------------ | ------------------------------ |
| `<leader>vc` | **Actions Vue**    | Actions de code Vue            |
| `<leader>vr` | **Renommer Vue**   | Renommer dans composant Vue    |
| `<leader>vs` | **Template Vue 2** | Single File Component Vue 2    |
| `<leader>v3` | **Template Vue 3** | Template Vue 3 Composition API |

### Console Operations

| Raccourci     | Action            | Description           |
| ------------- | ----------------- | --------------------- |
| `<leader>jcl` | **console.log**   | Insérer console.log   |
| `<leader>jce` | **console.error** | Insérer console.error |
| `<leader>jcw` | **console.warn**  | Insérer console.warn  |
| `<leader>jci` | **console.info**  | Insérer console.info  |

---

## 📝 Développement Markdown

### Formatage & Linting

| Raccourci    | Action              | Description                                                |
| ------------ | ------------------- | ---------------------------------------------------------- |
| `<leader>mf` | **Format Markdown** | Prettier + markdownlint --fix (corrige MD058, MD022, etc.) |
| `<leader>ml` | **Lint Markdown**   | Vérifier avec markdownlint (sans corriger)                 |
| `<leader>mc` | **Corriger tout**   | Format + lint + vérification finale                        |
| `<leader>ma` | **Actions de code** | Actions de code LSP                                        |

**Note**: Les erreurs MD058 (espaces autour tables) et MD022 (espaces autour titres) sont corrigées automatiquement avec `<leader>mf` ou `<leader>mc`.

---

## 🔧 Utilitaires & Interface

### Toggles Interface

| Raccourci    | Action             | Description                    |
| ------------ | ------------------ | ------------------------------ |
| `<leader>uf` | **Auto-format**    | Basculer formatage automatique |
| `<leader>us` | **Spell check**    | Correction orthographique      |
| `<leader>uw` | **Word wrap**      | Retour à la ligne automatique  |
| `<leader>ul` | **Numéros lignes** | Basculer numérotation          |
| `<leader>uC` | **Colorscheme**    | Prévisualiser thèmes           |
| `<leader>ur` | **Redraw**         | Rafraîchir l'écran             |

### Correcteur Orthographique (Français + Anglais)

| Raccourci | Action                   | Description                           |
| --------- | ------------------------ | ------------------------------------- |
| `]s`      | **Erreur suivante**      | Aller à l'erreur suivante             |
| `[s`      | **Erreur précédente**    | Aller à l'erreur précédente           |
| `z=`      | **Suggestions**          | Afficher suggestions de correction    |
| `zg`      | **Ajouter au dico**      | Ajouter le mot au dictionnaire        |
| `zw`      | **Marquer incorrect**    | Marquer le mot comme incorrect        |
| `zug`     | **Retirer du dico**      | Retirer le mot du dictionnaire perso  |

### Git Operations

| Raccourci     | Action                     | Description                 |
| ------------- | -------------------------- | --------------------------- |
| `<leader>gg`  | **Lazygit**                | Interface Git complète      |
| `<leader>gf`  | **Historique fichier**     | Historique Git du fichier   |
| `<leader>gF`  | **Historique fichier (diff)** | Historique du fichier avec diff interactif (Diffview) |
| `<leader>gd`  | **Diff View**              | Diff working tree vs HEAD (Diffview) |
| `<leader>gD`  | **Fermer Diff View**       | Fermer la vue diff (Diffview) |
| `<leader>gc`  | **Commits**                | Naviguer dans les commits   |
| `<leader>gs`  | **Statut Git**             | Statut du repository        |
| `]h` / `[h`   | **Hunk suivant/précédent** | Navigation dans les changes |
| `<leader>ghs` | **Stage hunk**             | Ajouter le changement       |

#### Conventional Commits (ft: gitcommit uniquement)

| Raccourci    | Action                        | Description                                      |
| ------------ | ----------------------------- | ------------------------------------------------ |
| `<leader>gc` | **Conventional Commit**       | Sélecteur de type de commit (feat, fix, chore…) |

### Terminal Persistant (ToggleTerm)

| Raccourci    | Action                       | Description                                               |
| ------------ | ---------------------------- | --------------------------------------------------------- |
| `<Ctrl-\>`   | **Toggle terminal flottant** | Ouvrir/fermer terminal flottant (mode normal et terminal) |
| `<leader>tf` | **Terminal flottant**        | Ouvrir terminal flottant                                  |
| `<leader>th` | **Terminal horizontal**      | Ouvrir terminal en split horizontal (bas)                 |
| `<leader>tv` | **Terminal vertical**        | Ouvrir terminal en split vertical (droite)                |

**Dans le terminal:**

| Raccourci        | Action              | Description                                     |
| ---------------- | ------------------- | ----------------------------------------------- |
| `<Esc>`          | **Fermer terminal** | Fermer la fenêtre terminal (contenu persistant) |
| `<Ctrl-h/j/k/l>` | **Navigation**      | Naviguer vers autres fenêtres depuis terminal   |

### Session & Sauvegarde

| Raccourci  | Action              | Description                                |
| ---------- | ------------------- | ------------------------------------------ |
| `<Ctrl-s>` | **Sauvegarder**     | Sauvegarder le fichier                     |
| `<Esc>`    | **Clear highlight** | Effacer surlignage recherche (mode normal) |

---

## 📚 Découverte & Aide

### Apprentissage

| Raccourci            | Action                   | Description                       |
| -------------------- | ------------------------ | --------------------------------- |
| `<leader>K`          | **Afficher keymaps**     | Ouvrir KEYMAPS.md en preview      |
| `<leader>sk`         | **Recherche keymaps**    | Chercher dans tous les raccourcis |
| `<leader>sh`         | **Pages d'aide**         | Documentation Neovim              |
| `<leader>:`          | **Historique commandes** | Historique des commandes          |
| `:Telescope keymaps` | **Browse keymaps**       | Parcourir tous les raccourcis     |

### Plugin Management

| Raccourci   | Action           | Description             |
| ----------- | ---------------- | ----------------------- |
| `<leader>l` | **Lazy Manager** | Gestionnaire de plugins |

---

## 🎯 Conseils d'Usage

### 🔥 **Raccourcis Essentiels**

1. `<leader><space>` - Trouver fichiers (le plus utilisé)
2. `<leader>/` - Recherche globale
3. `<Ctrl-\>` - Terminal flottant persistant
4. `<leader>aa` - Ouvrir Claude IA
5. `<leader>ca` - Actions de code
6. `<Ctrl-h/j/k/l>` - Navigation fenêtres

### 💡 **Découverte**

- Pressez `<leader>` et **attendez** → Menu des raccourcis disponibles
- Utilisez `<leader>sk` pour chercher un raccourci spécifique
- La plupart des plugins ajoutent leurs raccourcis sous leur lettre (`g` pour Git, `t` pour Tests, etc.)

### 🚀 **Workflow Recommandé**

1. **Navigation**: `<leader><space>` → fichier
2. **Code**: `<leader>ca` → actions rapides
3. **IA**: `<leader>aa` → Claude, `<leader>ap` → expert PHP
4. **Debug**: `<leader>db` → breakpoints
5. **Tests**: `<leader>tn` → test proche

---
