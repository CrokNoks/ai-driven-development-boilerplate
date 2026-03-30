---
description: Start the Autonomous AI Developer Pipeline sequence with a new idea
---

## Syntaxe

```
/startcycle <idea>
```

Exemples :
```
/startcycle "une app de gestion de tâches"
/startcycle "ajouter l'authentification OAuth"
```

## Execution Sequence

### Détecter le mode
Vérifie si `app_build/` existe et contient un dépôt Git :

```bash
[ -d app_build/.git ] && echo "existing" || echo "greenfield"
```

- Si `app_build/.git` existe → `MODE = existing`
- Sinon → `MODE = greenfield`

Mettre à jour `.agents/state/active.json` avec `mode` avant de continuer.

### Étape 1 — Spécification (PM)
- **Mode greenfield** → exécute `write_specs.md`
- **Mode existing** → exécute `write_change_spec.md`

*(Boucle de révision jusqu'à l'approbation explicite de l'utilisateur.)*

### Étape 2 — Développement parallèle (Orchestrateur)
Une fois la spec approuvée, exécute le workflow `parallel_roles.md`.

Ce workflow gère Engineer, Tester et Reviewer séquentiellement sur la branche `feature/{FEATURE_ID}`.
Il route les bons skills selon le mode :
- Engineer → `generate_code.md` (greenfield) ou `modify_code.md` (existing)
- Tester → `test_code.md` dans les deux modes
- Reviewer → `review_pr.md` dans les deux modes
