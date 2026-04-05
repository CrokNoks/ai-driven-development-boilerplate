# Skill: Modify Code

## Objectif
Appliquer les modifications décrites dans le Change Request sur la codebase existante.
Ce skill remplace `generate_code.md` en mode `existing`.

## Règles de base
- **Lire avant d'écrire** : ne jamais modifier un fichier sans l'avoir lu en entier
- **Scope strict** : ne toucher qu'aux fichiers listés dans le Change Request
- **Cohérence** : respecter les conventions, patterns et style du code existant

## Instructions

### Étape 1 — Créer la branche feature
```bash
cd {APP_BUILD_PATH}
git checkout main
git pull
git checkout -b feature/{FEATURE_ID}
```

### Étape 2 — Lire le Change Request et la documentation
Ouvre `{APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md` et identifie :
Lis également tous les autres fichiers dans `{APP_BUILD_PATH}/docs/{FEATURE_ID}/`
ainsi que la documentation globale dans `{APP_BUILD_PATH}/docs/` (api.md, architecture.md…).
- Les fichiers à créer
- Les fichiers à modifier
- Les fichiers hors scope (ne pas toucher)

### Étape 3 — Comprendre le code existant
Pour chaque fichier listé dans "Fichiers à modifier" :
1. Lis le fichier complet
2. Identifie les fonctions, classes, ou modules impactés
3. Repère les dépendances internes (imports, appels)

### Étape 4 — Implémenter les modifications
Pour chaque fichier à créer ou modifier :
1. Applique uniquement les changements du Change Request
2. Respecte le style de code existant (indentation, nommage, patterns)
3. Ne pas refactoriser du code hors scope
4. Vérifie que les imports et dépendances déclarées sont à jour

### Étape 5 — Valider les modifications

Avant de commiter, vérifie que le code existant + les modifications sont sains.

**Installer les nouvelles dépendances** si la spec en introduit :
```bash
npm install 2>/dev/null || pnpm install 2>/dev/null || pip install -r requirements.txt 2>/dev/null || true
```

**Compiler / vérifier la syntaxe** :
```bash
npx tsc --noEmit 2>/dev/null || go build ./... 2>/dev/null || cargo check 2>/dev/null || true
```

**Linter** :
```bash
npm run lint 2>/dev/null || true
```

**Vérifier l'absence de secrets hardcodés** dans les fichiers modifiés :
```bash
git diff --name-only HEAD | xargs grep -lnE "(API_KEY|SECRET|PASSWORD|TOKEN)\s*=\s*[\"'][^\"']{8,}" 2>/dev/null || true
```

Si build ou lint échoue : corrige avant de commiter (max 1 tentative). Si l'erreur persiste, note-la dans le commit message.

### Étape 6 — Commiter
```bash
cd {APP_BUILD_PATH}
git add .
git commit -m "feat({FEATURE_ID}): modifications par l'agent Engineer"
```

### Étape 7 — Mettre à jour le manifest
Dans `{REPO_PATH}/.agents/state/active.json` :
```json
"features": {
  "{FEATURE_ID}": {
    "phase": "engineer_done",
    "roles": {
      "engineer": { "status": "done" }
    }
  }
}
```
