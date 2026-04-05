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

### Étape 1 — Spécification (PM + Assistants)

1. **Phase Q&A (PM)** : Le PM dialogue avec l'utilisateur pour clarifier le besoin.
2. **Rédaction du brouillon (PM)** : 
   - **Mode greenfield** → exécute `write_specs.md`
   - **Mode existing** → exécute `write_change_spec.md`
3. **Vérification (Assistants)** :
   - `@spec_checker` → exécute `check_spec_completeness.md`
   - `@spec_challenger` → exécute `challenge_spec_choices.md`
   *(Feedback visible dans le chat)*
4. **Révision & Présentation (PM)** : Le PM ajuste la spec selon les retours des assistants et la présente pour validation finale.

*(Boucle de révision jusqu'à l'approbation explicite de l'utilisateur.)*

### Étape 2 — Développement séquentiel (Orchestrateur)
Une fois la spec approuvée, exécute le workflow `sequential_roles.md`.

Ce workflow gère Engineer, Tester, Reviewer et Doc Writer séquentiellement sur la branche `feature/{FEATURE_ID}`.
Il route les bons skills selon le mode :
- Engineer → `generate_code.md` (greenfield) ou `modify_code.md` (existing)
- Tester → `test_code.md` dans les deux modes
- Reviewer → `review_pr.md` dans les deux modes
