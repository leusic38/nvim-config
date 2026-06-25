# Configuration Claude Code dans Neovim

## 🔑 Configuration de la clé API

### 1. Obtenir une clé API Anthropic
1. Aller sur https://console.anthropic.com/
2. Créer un compte ou se connecter
3. Aller dans "API Keys"
4. Créer une nouvelle clé API
5. Copier la clé (commence par `sk-ant-...`)

### 2. Configurer la variable d'environnement

Ajouter à votre `~/.zshrc` ou `~/.bashrc` :
```bash
export ANTHROPIC_API_KEY="sk-ant-votre-cle-ici"
```

Puis recharger :
```bash
source ~/.zshrc
```

### 3. Vérifier la configuration
```bash
echo $ANTHROPIC_API_KEY
```

## 🎯 Raccourcis configurés

### Chat & Actions
- `<leader>aa` : Ouvrir le menu d'actions CodeCompanion
- `<leader>ac` : Basculer le chat Claude
- `<leader>ap` : Ajouter la sélection au chat (mode visuel)

### Assistance inline
- `<leader>ai` : Assistant inline
- `<leader>aq` : Aide PHP rapide
- `<leader>ae` : Expliquer le code
- `<leader>ar` : Refactoriser le code  
- `<leader>af` : Corriger le code
- `<leader>at` : Générer des tests
- `<leader>ad` : Générer la documentation

### Utilitaires
- `<leader>yc` : Copier au format Claude (`@filename#L10-20`)
- `:cc` : Raccourci pour `:CodeCompanion`

## 🚀 Utilisation

1. **Chat contextuel** : Sélectionner du code + `<leader>ap`
2. **Aide PHP** : `<leader>aq` pour une assistance PHP experte  
3. **Refactoring** : Sélectionner code + `<leader>ar`
4. **Debug** : Sélectionner code + `<leader>af`

## 📋 Modèles disponibles
- `claude-3-5-sonnet-20241022` (par défaut, le plus puissant)
- `claude-3-5-haiku-20241022` (plus rapide, moins cher)
- `claude-3-opus-20240229` (le plus créatif)

Le modèle peut être changé dans le chat avec `/model claude-3-5-haiku-20241022`