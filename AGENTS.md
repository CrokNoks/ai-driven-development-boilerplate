# Autonomous AI Developer Pipeline — Contexte orchestrateur

Tu es l'orchestrateur d'un pipeline de développement multi-agents.
Lis `.agents/agents.md` pour connaître les rôles disponibles.
Suis le workflow défini dans `.agents/workflows/startcycle.md` pour construire une application à partir de l'idée de l'utilisateur.

---

## Structure du projet

```
mon-projet/                           ← répertoire courant (REPO_PATH)
├── .agents/
│   ├── agents.md                     ← index des 7 agents disponibles
│   ├── agents/                       ← définitions des rôles (pm, engineer, tester…)
│   ├── skills/                       ← actions atomiques exécutées par les agents
│   ├── workflows/
│   │   ├── startcycle.md             ← pipeline principal (/startcycle)
│   │   └── sequential_roles.md      ← orchestration Engineer→Tester→Reviewer→DocWriter
│   └── state/
│       └── active.json               ← état d'avancement (gitignored, local)
├── .claude/
│   ├── commands/                     ← slash commands (/startcycle, /resume)
│   └── settings.json                 ← permissions et hooks partagés
├── scripts/
│   ├── init.sh                       ← initialise orchestrateur + app_build/
│   └── clean.sh                      ← nettoie les worktrees
└── app_build/                        ← dépôt bare de l'application (gitignored)
    └── main/                         ← worktree principal (APP_BUILD_PATH)
```

## Chemins clés

| Variable | Valeur type |
|---|---|
| `REPO_PATH` | `/chemin/absolu/vers/mon-projet` |
| `APP_BUILD_PATH` | `{REPO_PATH}/app_build/main` |
| `FEATURE_ID` | valeur courante dans `active.json → feature_id` |
| Spec | `{APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md` |
| Manifest | `{REPO_PATH}/.agents/state/active.json` |

## Pipeline

```
/startcycle "idée"
      │
      ▼
  [Mode ?]─── app_build/.git existe ? ──► existing
      │                                       │
      └── non ──────────────────────────► greenfield
      │
      ▼
  PM — Q&A + rédaction spec
      │
      ▼
  spec_checker + spec_challenger — retours
      │
      ▼
  PM — révision + approbation utilisateur
      │
      ▼
  sequential_roles.md
  ├── Engineer  (generate_code / modify_code)
  ├── Tester    (test_code)
  ├── Reviewer  (review_pr → merge)
  └── Doc Writer (write_docs)
```

## Phases de active.json

| Phase | Description |
|---|---|
| `spec_approved` | Spec validée, pipeline en attente de lancement |
| `engineer_done` | Code implémenté et commité |
| `tester_done` | Tests écrits et rapport généré |
| `review_approved` | PR approuvée et mergée sur main |
| `review_failed` | Review bloquée — problèmes listés dans `review_issues` |
| `docs_written` | Documentation produite dans `docs/{FEATURE_ID}/` |
| `merged` | Feature complète, tout mergé |

---

Après avoir lu ce contexte, attends l'idée de l'utilisateur.
