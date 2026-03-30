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

### Étape 2 — Lire le Change Request
Ouvre `{REPO_PATH}/production_artifacts/{FEATURE_ID}/Technical_Specification.md` et identifie :
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

### Étape 5 — Commiter
```bash
cd {APP_BUILD_PATH}
git add .
git commit -m "feat({FEATURE_ID}): modifications par l'agent Engineer"
```

### Étape 6 — Mettre à jour le manifest
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
