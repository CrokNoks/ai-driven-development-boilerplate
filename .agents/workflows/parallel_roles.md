# Workflow: Sequential Roles

Ce workflow est déclenché après l'approbation de la spec par l'utilisateur.
L'Engineer crée la branche feature, puis chaque agent travaille séquentiellement
sur cette même branche.

## Vue d'ensemble

```
[Spec approuvée]
      │
      ▼
  Engineer → crée feature/{FEATURE_ID}, implémente, commit
      │
      ▼
   Tester → écrit et exécute les tests, commit
      │
      ▼
 Reviewer → review + PR → merge main
      │
      ▼
Doc Writer → fonctionnalites.md, specs.md, points_attention.md, index.md
```

## Étapes

### 1. Lancer l'agent Engineer
Lance un sous-agent avec le prompt suivant :

```
Tu es un agent IA jouant le rôle de Full-Stack Engineer.
Ton répertoire de travail est : {APP_BUILD_PATH}
La spec se trouve dans : {APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json
Le FEATURE_ID est : {FEATURE_ID}

Lis le skill {REPO_PATH}/.agents/skills/generate_code.md (greenfield)
           ou {REPO_PATH}/.agents/skills/modify_code.md  (existing)
et exécute-le à la lettre.
```

Attends que l'Engineer ait le statut `"done"` dans `active.json` avant de continuer.

### 2. Lancer l'agent Tester
Lance un sous-agent avec le prompt suivant :

```
Tu es un agent IA jouant le rôle de Test Engineer.
Ton répertoire de travail est : {APP_BUILD_PATH}
La spec se trouve dans : {APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json
Le FEATURE_ID est : {FEATURE_ID}

Lis le skill {REPO_PATH}/.agents/skills/test_code.md
et exécute-le à la lettre.
```

Attends que le Tester ait le statut `"done"` dans `active.json` avant de continuer.

### 3. Lancer l'agent Reviewer
Lance un sous-agent avec le prompt suivant :

```
Tu es un agent IA jouant le rôle de Code Reviewer.
Ton répertoire de travail est : {APP_BUILD_PATH}
La spec se trouve dans : {APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json
Le FEATURE_ID est : {FEATURE_ID}

Ton rôle CRUCIAL : Vérifier que le code implémente FIDÈLEMENT la spécification technique approuvée.
Ne laisse passer aucun écart de plan ou dérive de scope.

Lis le skill {REPO_PATH}/.agents/skills/review_pr.md
et exécute-le à la lettre.
```

**Attends la décision du Reviewer** :
- Phase `"review_approved"` → la PR est mergée sur `main`, continuer à l'étape 4
- Phase `"review_failed"` → informe l'utilisateur des problèmes et demande comment procéder

### 4. Lancer l'agent Doc Writer
Lance un sous-agent avec le prompt suivant :

```
Tu es un agent IA jouant le rôle de Documentation Writer.
Ton répertoire de travail est : {APP_BUILD_PATH}
La spec se trouve dans : {APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json
Le FEATURE_ID est : {FEATURE_ID}

Lis le skill {REPO_PATH}/.agents/skills/write_docs.md
et exécute-le à la lettre.
```

Attends que le Doc Writer ait le statut `"docs_written"` dans `active.json`.

Une fois terminé : **pipeline complet**, annonce la fin avec le résumé de la documentation produite.
