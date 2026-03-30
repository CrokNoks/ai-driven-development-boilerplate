# Skill: Generate Code

## Objectif
Créer la branche feature et implémenter l'application complète selon la spec du PM.

## Règles de base
- **Répertoire de travail** : `app_build/`
- **Lecture seule** : `production_artifacts/Technical_Specification.md`
- **Écriture** : tous les fichiers de l'application dans `app_build/`

## Instructions

### Étape 1 — Lire la spec
Ouvre et étudie attentivement `{REPO_PATH}/production_artifacts/{FEATURE_ID}/Technical_Specification.md`.
Identifie la stack technique, les fonctionnalités et l'architecture attendues.

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

### Étape 4 — Commiter
```bash
cd {APP_BUILD_PATH}
git add .
git commit -m "feat({FEATURE_ID}): implémentation initiale par l'agent Engineer"
```

### Étape 5 — Mettre à jour le manifest
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
