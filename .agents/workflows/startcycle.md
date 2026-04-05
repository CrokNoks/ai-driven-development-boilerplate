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

### Détecter le mode et le type

**Mode** — Vérifie si `app_build/main/` existe (worktree principal du bare repo) :

```bash
[ -d app_build/main ] && echo "existing" || echo "greenfield"
```

- Si `app_build/main/` existe → `MODE = existing`
- Sinon → `MODE = greenfield` → **initialiser automatiquement l'environnement**

**Type** — Détermine s'il s'agit d'une nouvelle fonctionnalité ou d'une correction de bug :

- Si `MODE = greenfield` → `TYPE = feature` (pas de codebase, impossible d'avoir un bug)
- Si `MODE = existing` → analyse l'idée de l'utilisateur :
  - Mots-clés bug : "fix", "bug", "erreur", "correction", "ne fonctionne pas", "crash",
    "réparer", "casse", "broken", "régression" → propose `TYPE = bugfix`
  - Sinon → propose `TYPE = feature`
  - Si le type n'est pas évident, demande confirmation : *"Est-ce une nouvelle fonctionnalité
    ou une correction de bug ?"*

Mettre à jour `.agents/state/active.json` avec `mode` et `type` avant de continuer.

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

### Étape 1A — Spécification feature (PM + Architect + Assistants)

*Ce chemin s'applique quand `TYPE = feature`.*

1. **Phase Q&A (PM)** `[modèle : sonnet]` : Le PM dialogue avec l'utilisateur pour clarifier le besoin (QUOI : fonctionnalités, utilisateurs, critères de succès). Le PM dérive le `FEATURE_ID` et le sauvegarde dans `active.json`.
2. **Recommandation de stack (Architect)** `[modèle : sonnet]` *(greenfield uniquement)* : L'Architect mène un Q&A technique (COMMENT/OÙ : plateforme, environnement, scale, données, équipe) et produit `app_build/docs/{FEATURE_ID}/stack_recommendation.md`. Le PM attend la validation avant de continuer.
3. **Rédaction du brouillon (PM)** `[modèle : sonnet]` :
   - **Mode greenfield** → exécute `write_specs.md` (lit `stack_recommendation.md` pour la section Stack)
   - **Mode existing** → exécute `write_change_spec.md`
4. **Vérification (Assistants)** :
   - `@spec_checker` `[modèle : haiku]` → exécute `check_spec_completeness.md`
   - `@spec_challenger` `[modèle : sonnet]` → exécute `challenge_spec_choices.md`
   *(Feedback visible dans le chat)*
5. **Révision & Présentation (PM)** `[modèle : sonnet]` : Le PM ajuste la spec selon les retours des assistants et la présente pour validation finale.

*(Boucle de révision jusqu'à l'approbation explicite de l'utilisateur.)*

---

### Étape 1B — Bug Report (PM)

*Ce chemin s'applique quand `TYPE = bugfix`.*

1. **Q&A bug (PM)** `[modèle : sonnet]` : Le PM exécute `write_bug_report.md`. Il collecte les étapes de reproduction, le comportement observé vs attendu, le composant suspect et la sévérité. Pas d'Architect, pas de spec_checker/challenger — le Bug Report est directement soumis à validation.
2. **Validation utilisateur** : Le PM présente le Bug Report dans le chat. L'utilisateur approuve ou corrige.

*(Boucle de révision jusqu'à l'approbation explicite de l'utilisateur.)*

### Étape 2 — Développement séquentiel (Orchestrateur)

Une fois le Bug Report ou la spec approuvé(e), exécute le workflow `sequential_roles.md`.

Ce workflow gère les agents séquentiellement sur la branche `feature/{ID}` (feature) ou `fix/{ID}` (bugfix).
Il route les bons skills selon le mode **et le type** :

| Agent | TYPE = feature | TYPE = bugfix |
|---|---|---|
| Engineer | `generate_code.md` (greenfield) ou `modify_code.md` (existing) | `fix_bug.md` |
| Tester | `test_code.md` | `test_code.md` |
| Reviewer | `review_pr.md` | `review_pr.md` |
| Doc Writer | `write_docs.md` | *(ignoré)* |
| Changelog | `write_changelog.md` | `write_changelog.md` |
