# Workflow: Parallel Roles

Ce workflow est déclenché après l'approbation de la spec par l'utilisateur.
Il remplace les étapes 2-4 du workflow `startcycle.md` (séquentiel) par une
exécution parallèle des rôles Engineer, QA, et DevOps.

## Vue d'ensemble

```
[Spec approuvée]
      │
      ▼
[create_worktrees] → 3 worktrees créés + CLAUDE.md injectés
      │
      ├──── Agent Engineer (background) ──────┐
      ├──── Agent QA      (background) ───────┼──→ [merge_roles] → [deploy]
      └──── Agent DevOps  (background) ──────┘
```

## Étapes

### 1. Préparer les worktrees
Agis en tant qu'**Orchestrateur** et exécute le skill `create_worktrees.md`.
Ce skill crée les 3 worktrees, injecte les CLAUDE.md et met à jour `active.json`.

### 2. Lancer les 3 agents en parallèle
Lance 3 sous-agents simultanément (run_in_background: true), un par rôle.
Pour chaque agent, le prompt suit ce modèle :

```
Tu es un agent IA travaillant dans un worktree Git isolé.
Ton répertoire de travail est : {WORKTREE_PATH}
Commence par lire le fichier CLAUDE.md situé à {WORKTREE_PATH}/CLAUDE.md.
Ce fichier contient ton briefing complet, tes règles absolues, et le skill à exécuter.
Suis-le à la lettre.
```

Les 3 agents ont chacun leur propre chemin de worktree issu du manifest `active.json`.

### 3. Monitorer la progression
Surveille `.agents/state/active.json` pour suivre le statut des agents.
Tu peux informer l'utilisateur de la progression :
- `running` → en cours
- `done`    → terminé
- `error`   → échec (demander à l'utilisateur comment procéder)

### 4. Attendre la complétion
Attend que les 3 agents soient au statut `"done"` dans `active.json`.

### 5. Merger et déployer
Exécute le skill `merge_roles.md` pour fusionner les branches,
puis exécute le skill `deploy_app.md` sur la branche feature fusionnée.
