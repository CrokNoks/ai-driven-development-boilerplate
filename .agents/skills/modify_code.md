# Skill: Modify Code

## Objectif
Appliquer les modifications décrites dans le Change Request sur une codebase existante.
Ce skill remplace `generate_code.md` en mode `--existing`.

## Différence avec generate_code.md
`generate_code.md` scaffolde une application from scratch dans `app_build/`.
Ce skill **lit le code existant** et applique des modifications chirurgicales.

## Règles de base
- **Lire avant d'écrire** : tu ne modifies jamais un fichier sans l'avoir lu en entier
- **Scope strict** : tu ne touches qu'aux fichiers listés dans le Change Request
- **Cohérence** : respecte les conventions, patterns et style du code existant
- **Contrat API** : publie `production_artifacts/api_contract.md` dès que les
  interfaces sont stabilisées (pour permettre au QA de démarrer)

## Instructions

### Étape 1 — Lire le Change Request
Ouvre `production_artifacts/Technical_Specification.md` et identifie :
- Les fichiers à créer
- Les fichiers à modifier
- Les fichiers hors scope (ne pas toucher)
- Les interfaces à implémenter

### Étape 2 — Comprendre le code existant
Pour chaque fichier listé dans "Fichiers à modifier" :
1. Lis le fichier complet
2. Identifie les fonctions, classes, ou modules impactés
3. Repère les dépendances internes (imports, appels)

### Étape 3 — Publier le contrat API
Dès que tu as défini les nouvelles interfaces (fonctions, endpoints, types) :
Écris `{REPO_PATH}/production_artifacts/api_contract.md` avec :
```markdown
# API Contract

## Nouvelles interfaces
...

## Interfaces modifiées
...

## Types / Schémas
...
```
Cela permet au QA de démarrer ses tests sans attendre le code complet.

### Étape 4 — Implémenter les modifications
Pour chaque fichier à créer ou modifier :
1. Applique uniquement les changements du Change Request
2. Respecte le style de code existant (indentation, nommage, patterns)
3. Ne pas refactoriser du code hors scope, même si tu penses que c'est améliorable
4. Sauvegarde dans `{WORKTREE_PATH}/{CODEBASE_DIR}/`

### Étape 5 — Vérifier la cohérence
- Vérifie que les imports sont corrects
- Vérifie que les fichiers modifiés restent syntaxiquement valides
- Vérifie que les dépendances déclarées dans `package.json` / `requirements.txt` / etc.
  couvrent les nouvelles librairies utilisées

### Étape 6 — Mettre à jour le manifest
`{REPO_PATH}/.agents/state/active.json` → `worktrees.engineer.status = "done"`
