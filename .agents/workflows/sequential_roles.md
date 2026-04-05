# Workflow: Sequential Roles

Ce workflow est déclenché après l'approbation de la spec par l'utilisateur.
L'Engineer crée la branche feature, puis chaque agent travaille séquentiellement
sur cette même branche.

## Vue d'ensemble

```
[Spec approuvée]
      │
      ▼
  Engineer (sonnet) → crée feature/{FEATURE_ID}, implémente, valide build/lint, commit
      │
      ▼
   Tester (sonnet) → écrit et exécute les tests, commit
      │
      ▼
 Reviewer (sonnet) → review + sécurité + PR → merge main
      │
      ▼
Doc Writer (haiku) → fonctionnalites.md, specs.md, points_attention.md, index.md
      │
      ▼
Changelog (haiku) → CHANGELOG.md mis à jour, phase = merged
```

## Résolution des variables

Avant de lancer les sous-agents, résous les variables suivantes depuis `active.json` :

```
REPO_PATH      = répertoire racine de l'orchestrateur (là où se trouve .agents/)
FEATURE_ID     = active.json → feature_id
CODEBASE_DIR   = active.json → features[FEATURE_ID].codebase_dir
APP_BUILD_PATH = REPO_PATH + "/" + CODEBASE_DIR
                 (exemple : /home/user/mon-projet/app_build/main)
MODE           = active.json → features[FEATURE_ID].mode  (greenfield | existing)
TYPE           = active.json → features[FEATURE_ID].type  (feature | bugfix)
SPEC_PATH      = active.json → features[FEATURE_ID].spec_path
                 (exemple : docs/my_feature/Technical_Specification.md
                          ou docs/bugs/login_oauth_redirect/Bug_Report.md)
BRANCH_PREFIX  = "feature" si TYPE = feature, "fix" si TYPE = bugfix
```

Pour obtenir `REPO_PATH` dans le contexte d'un sous-agent, utilise le chemin absolu
du répertoire courant au moment de l'invocation du workflow.

## Modèles par agent

Chaque sous-agent est lancé avec le modèle défini dans le frontmatter de son fichier agent.
Le modèle est indiqué dans chaque étape ci-dessous. Pour changer le modèle d'un agent,
modifie le champ `model:` dans `.agents/agents/{role}.md`.

## Étapes

### 1. Lancer l'agent Engineer — modèle `sonnet`

Lance un sous-agent **avec le modèle `sonnet`** avec le prompt suivant (variables résolues) :

```
Tu es un agent IA jouant le rôle de Full-Stack Engineer.
Ton répertoire de travail est : {APP_BUILD_PATH}
La spec se trouve dans : {APP_BUILD_PATH}/{SPEC_PATH}
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json
Le FEATURE_ID est : {FEATURE_ID}
Le TYPE est : {TYPE}  (feature | bugfix)

Lis d'abord le profil du rôle : {REPO_PATH}/.agents/agents/engineer.md
Puis lis le skill correspondant au type et au mode :
  - TYPE=feature, MODE=greenfield → {REPO_PATH}/.agents/skills/generate_code.md
  - TYPE=feature, MODE=existing  → {REPO_PATH}/.agents/skills/modify_code.md
  - TYPE=bugfix                  → {REPO_PATH}/.agents/skills/fix_bug.md
et exécute-le à la lettre.
```

Attends que le statut de la feature dans `active.json` passe à `"engineer_done"` avant de continuer.

### 2. Lancer l'agent Tester — modèle `sonnet`

Lance un sous-agent **avec le modèle `sonnet`** avec le prompt suivant (variables résolues) :

```
Tu es un agent IA jouant le rôle de Test Engineer.
Ton répertoire de travail est : {APP_BUILD_PATH}
La spec se trouve dans : {APP_BUILD_PATH}/{SPEC_PATH}
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json
Le FEATURE_ID est : {FEATURE_ID}
Le TYPE est : {TYPE}

Lis d'abord le profil du rôle : {REPO_PATH}/.agents/agents/tester.md
Puis lis le skill {REPO_PATH}/.agents/skills/test_code.md
et exécute-le à la lettre.
Si TYPE=bugfix, assure-toi que les tests vérifient spécifiquement la correction
du bug décrit dans le Bug Report (test de non-régression).
```

Attends que le statut de la feature dans `active.json` passe à `"tester_done"` avant de continuer.

### 3. Lancer l'agent Reviewer — modèle `sonnet`

Lance un sous-agent **avec le modèle `sonnet`** avec le prompt suivant (variables résolues) :

```
Tu es un agent IA jouant le rôle de Code Reviewer.
Ton répertoire de travail est : {APP_BUILD_PATH}
La spec se trouve dans : {APP_BUILD_PATH}/{SPEC_PATH}
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json
Le FEATURE_ID est : {FEATURE_ID}
Le TYPE est : {TYPE}

Lis d'abord le profil du rôle : {REPO_PATH}/.agents/agents/reviewer.md
Puis lis le skill {REPO_PATH}/.agents/skills/review_pr.md
et exécute-le à la lettre.
```

**Attends la décision du Reviewer** :
- Phase `"review_approved"` → la PR est mergée sur `main`, continuer à l'étape 4
- Phase `"review_failed"` → informe l'utilisateur des problèmes listés dans `active.json → review_issues` et demande comment procéder

### 4. Lancer l'agent Doc Writer — modèle `haiku` *(TYPE = feature uniquement)*

**Si `TYPE = bugfix` : saute cette étape** et passe directement à l'étape 5.
Met à jour `active.json` → `phase: "docs_written"` sans lancer de sous-agent.

Si `TYPE = feature`, lance un sous-agent **avec le modèle `haiku`** :

```
Tu es un agent IA jouant le rôle de Documentation Writer.
Ton répertoire de travail est : {APP_BUILD_PATH}
La spec se trouve dans : {APP_BUILD_PATH}/{SPEC_PATH}
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json
Le FEATURE_ID est : {FEATURE_ID}

Lis d'abord le profil du rôle : {REPO_PATH}/.agents/agents/doc_writer.md
Puis lis le skill {REPO_PATH}/.agents/skills/write_docs.md
et exécute-le à la lettre.
```

Attends que le statut de la feature dans `active.json` passe à `"docs_written"`.

### 5. Lancer l'agent Changelog — modèle `haiku`

Lance un sous-agent **avec le modèle `haiku`** avec le prompt suivant (variables résolues) :

```
Tu es un agent IA chargé de mettre à jour le changelog du projet.
Ton répertoire de travail est : {APP_BUILD_PATH}
La spec se trouve dans : {APP_BUILD_PATH}/{SPEC_PATH}
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json
Le FEATURE_ID est : {FEATURE_ID}
Le TYPE est : {TYPE}

Lis le skill {REPO_PATH}/.agents/skills/write_changelog.md
et exécute-le à la lettre.
Si TYPE=bugfix, utilise le préfixe "Fixed" dans l'entrée changelog (au lieu de "Added").
```

Attends que le statut de la feature dans `active.json` passe à `"merged"`.

Une fois terminé : **pipeline complet** — annonce la fin avec le résumé de la documentation et l'entrée changelog produite.
