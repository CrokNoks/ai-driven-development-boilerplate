---
description: Reprend un pipeline interrompu depuis la bonne phase
---

Reprends le pipeline pour la feature spécifiée (ou la feature courante si aucun argument).

## Syntaxe

```
/resume [feature_id]
```

Exemples :
```
/resume
/resume auth_oauth
/resume todo_app
```

## Comportement

### 1. Lire l'état actuel

Lis `.agents/state/active.json`.

- Si `feature_id` est fourni en argument → utilise-le
- Sinon → utilise `active.json → feature_id`

Résous les variables :
```
REPO_PATH      = répertoire racine de l'orchestrateur
FEATURE_ID     = feature_id résolu ci-dessus
APP_BUILD_PATH = REPO_PATH + "/" + active.json → features[FEATURE_ID].codebase_dir
MODE           = active.json → features[FEATURE_ID].mode
```

### 2. Router vers la bonne étape selon la phase

| Phase dans active.json | Action |
|---|---|
| `spec_approved` | Lancer `sequential_roles.md` depuis l'étape Engineer |
| `engineer_done` | Lancer `sequential_roles.md` depuis l'étape Tester |
| `tester_done` | Lancer `sequential_roles.md` depuis l'étape Reviewer |
| `review_approved` | Lancer `sequential_roles.md` depuis l'étape Doc Writer |
| `review_failed` | Afficher les problèmes listés dans `review_issues`, demander comment procéder |
| `docs_written` | Annoncer que le pipeline est terminé pour cette feature |
| `merged` | Annoncer que la feature est déjà complète |
| absent / inconnu | Demander à l'utilisateur de relancer `/startcycle` |

### 3. Informer l'utilisateur avant de reprendre

Affiche un résumé avant de lancer les agents :

```
---
**Reprise du pipeline** — `{FEATURE_ID}`

**Phase actuelle** : {phase}
**Prochaine étape** : {étape qui va être lancée}
**APP_BUILD_PATH** : {APP_BUILD_PATH}

Lecture de sequential_roles.md depuis l'étape {N}…
---
```

Puis exécute le workflow `sequential_roles.md` en partant de la bonne étape.
