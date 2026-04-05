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

### Vérifications pré-pipeline

Avant toute autre action, vérifie que l'environnement est opérationnel :

```bash
git --version
gh auth status
```

- Si `git` n'est pas installé → **stop** : "git est requis. Installe-le depuis https://git-scm.com"
- Si `gh auth status` échoue → **stop** : "gh CLI non authentifié — lance `gh auth login` puis relance /startcycle"

### Détecter le mode et initialiser l'environnement

Vérifie si `app_build/main/` existe (worktree principal du bare repo) :

```bash
[ -d app_build/main ] && echo "existing" || echo "greenfield"
```

- Si `app_build/main/` existe → `MODE = existing`
- Sinon → `MODE = greenfield` → **initialiser automatiquement l'environnement**

#### Initialisation automatique (greenfield uniquement)

Si `app_build/main/` n'existe pas, exécute les étapes suivantes **avant** de continuer :

**1. Créer le bare repo s'il n'existe pas :**
```bash
if [ ! -d app_build ]; then
  git init --bare app_build
fi
```

**2. Créer un commit initial si le repo est vide :**
```bash
if [ -z "$(git -C app_build branch 2>/dev/null)" ]; then
  TMPDIR_INIT=$(mktemp -d)
  git init "$TMPDIR_INIT"
  git -C "$TMPDIR_INIT" commit --allow-empty -m "chore: initial commit"
  git -C "$TMPDIR_INIT" remote add origin "$(pwd)/app_build"
  git -C "$TMPDIR_INIT" push origin HEAD:main
  rm -rf "$TMPDIR_INIT"
fi
```

**3. Créer le worktree `app_build/main/` :**
```bash
git -C app_build worktree add main main
```

Informe l'utilisateur : `"Environnement initialisé — app_build/main/ prêt."`

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
