---
description: Nettoie les worktrees et branches d'une feature ou de toutes les features
---

Exécute `scripts/clean.sh` pour supprimer proprement les worktrees, branches et entrées `active.json`.

## Syntaxe

```
/clean [feature_id]
```

Exemples :
```
/clean                  ← nettoie toutes les features
/clean todo_app         ← nettoie uniquement todo_app
```

## Comportement

### 1. Confirmer avec l'utilisateur

Avant d'exécuter, affiche ce qui va être supprimé :

- Si `feature_id` fourni : liste le worktree, la branche et l'entrée active.json de cette feature
- Si aucun argument : liste toutes les features actives dans active.json

Demande confirmation explicite avant de procéder.

### 2. Exécuter le script

```bash
# Pour une feature spécifique
bash scripts/clean.sh {feature_id}

# Pour toutes les features
bash scripts/clean.sh
```

### 3. Confirmer la fin

Affiche un résumé de ce qui a été supprimé.
