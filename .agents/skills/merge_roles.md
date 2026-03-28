# Skill: Merge Roles

## Objectif
Fusionner les branches des 3 agents (Engineer, QA, DevOps) d'une feature donnée
dans la branche feature principale, nettoyer les worktrees, et préparer le déploiement.

## Prérequis
- `FEATURE_ID` fourni en paramètre
- Les 3 agents de cette feature ont le statut `"done"` dans `active.json`
- On se trouve dans le repo principal (pas dans un worktree)

## Instructions

### Étape 1 — Vérifier que tout est terminé
Lis `.agents/state/active.json` → `features.{FEATURE_ID}.worktrees`.
Vérifie que les 3 `status` sont `"done"`.
Si l'un d'eux n'est pas `"done"`, **arrête-toi** et informe l'utilisateur.

### Étape 2 — Définir les variables
```
ORCHESTRATOR_PATH = répertoire courant de l'orchestrateur (chemin absolu)
APP_REPO_PATH     = {ORCHESTRATOR_PATH}/app_build
BRANCH_ENG        = feature/{FEATURE_ID}-impl
BRANCH_QA         = feature/{FEATURE_ID}-tests
BRANCH_DEV        = feature/{FEATURE_ID}-infra
```

### Étape 3 — Créer la branche feature principale
Les commandes git se lancent depuis `app_build/` (le dépôt de l'app).

```bash
cd {APP_REPO_PATH}
git checkout main
git checkout -b feature/{FEATURE_ID}
```

### Étape 4 — Merger dans l'ordre
L'ordre est important : le code d'abord, les tests ensuite, l'infra en dernier.

```bash
git merge --no-ff {BRANCH_ENG} -m "feat({FEATURE_ID}): implementation by Engineer agent"
git merge --no-ff {BRANCH_QA}  -m "test({FEATURE_ID}): test suite by QA agent"
git merge --no-ff {BRANCH_DEV} -m "chore({FEATURE_ID}): deployment config by DevOps agent"
```

En cas de conflit : lis les deux versions, applique la résolution la plus logique
selon la spec, commite avant de continuer.

### Étape 5 — Nettoyer les worktrees
Toujours depuis `app_build/` :

```bash
cd {APP_REPO_PATH}
git worktree remove {FEATURE_ID}/engineer
git worktree remove {FEATURE_ID}/qa
git worktree remove {FEATURE_ID}/devops

git branch -d {BRANCH_ENG}
git branch -d {BRANCH_QA}
git branch -d {BRANCH_DEV}
```

Si `{FEATURE_ID}/` est maintenant vide, le supprimer :
```bash
rmdir {APP_REPO_PATH}/{FEATURE_ID}
```

### Étape 6 — Mettre à jour le manifest
Dans `.agents/state/active.json`, mettre à jour uniquement l'entrée `{FEATURE_ID}` :

```json
"phase": "merged",
"worktrees": {
  "engineer": { "status": "merged" },
  "qa":       { "status": "merged" },
  "devops":   { "status": "merged" }
}
```

Ne pas modifier les autres features dans `active.json`.

### Étape 7 — Annoncer
Informe l'utilisateur que la branche `feature/{FEATURE_ID}` est prête pour le déploiement.
