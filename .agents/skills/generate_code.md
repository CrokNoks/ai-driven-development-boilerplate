# Skill: Generate Code

## Objectif
Créer la branche feature et implémenter l'application complète selon la spec du PM.

## Règles de base
- **Répertoire de travail** : `{APP_BUILD_PATH}`
- **Lecture seule** : `{APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md`
- **Écriture** : tous les fichiers de l'application dans `{APP_BUILD_PATH}`

## Instructions

### Étape 1 — Lire la spec et la documentation
Ouvre et étudie attentivement `{APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md`.
Identifie la stack technique, les fonctionnalités et l'architecture attendues.
Lis également tous les autres fichiers présents dans `{APP_BUILD_PATH}/docs/{FEATURE_ID}/`
(architecture, data model, API…) — ils font partie du brief.

### Étape 2 — Créer la branche feature
```bash
cd {APP_BUILD_PATH}
git checkout main
git pull
git checkout -b feature/{FEATURE_ID}
```

### Étape 3 — Implémenter l'application
Génère tous les fichiers de l'application dans `app_build/` :
- Structure de dossiers conforme à la spec
- Code complet (backend, frontend selon la stack)
- Fichiers de dépendances (`package.json`, `requirements.txt`, etc.)
- Ne pas résumer ni omettre de blocs de code

### Étape 4 — Valider l'implémentation

Avant de commiter, vérifie que le code est sain.

**Installer les dépendances** selon la stack détectée dans la spec :
```bash
# Node / npm
npm install
# Node / pnpm
pnpm install
# Python
pip install -r requirements.txt
# Go — pas d'install, les imports sont résolus au build
# Rust
cargo fetch
```

**Compiler / vérifier la syntaxe** si applicable :
```bash
# TypeScript
npx tsc --noEmit
# Go
go build ./...
# Rust
cargo check
# Python — pas de compilation, mais vérifier les imports critiques
python3 -c "import app" 2>/dev/null || true
```

**Linter** si un script est configuré dans le projet :
```bash
npm run lint 2>/dev/null || npx eslint . 2>/dev/null || true
```

**Vérifier l'absence de secrets hardcodés** :
```bash
grep -rn --include="*.ts" --include="*.js" --include="*.py" --include="*.go" \
  -E "(API_KEY|SECRET|PASSWORD|TOKEN)\s*=\s*[\"'][^\"']{8,}" . || true
```

Si build ou lint échoue : corrige les erreurs avant de passer à l'étape suivante (max 1 tentative d'auto-correction). Si l'erreur persiste, note-la dans le commit message.

### Étape 5 — Commiter
```bash
cd {APP_BUILD_PATH}
git add .
git commit -m "feat({FEATURE_ID}): implémentation initiale par l'agent Engineer"
```

### Étape 6 — Mettre à jour le manifest
Dans `{REPO_PATH}/.agents/state/active.json` :
(REPO_PATH = répertoire de l'orchestrateur, pas app_build)
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
