# Autonomous AI Developer Pipeline

Orchestrateur multi-agents (Claude Code / Gemini CLI) qui pilote le développement
d'une application de bout en bout — de la spécification au code reviewé et documenté.

## Compatibilité

| Fonctionnalité | Claude Code | Gemini CLI |
|---|---|---|
| Fichier de contexte projet | `CLAUDE.md` | `GEMINI.md` |
| Slash command `/startcycle` | `.claude/commands/` | `.gemini/commands/` |
| Skills `.agents/` | ✅ | ✅ |
| Scripts `scripts/` | ✅ | ✅ |

## Architecture

```
mon-projet/                 ← orchestrateur (ce dépôt)
└── app_build/
    └── main/               ← worktree principal de l'application
```

L'orchestrateur et l'application sont dans deux dépôts Git distincts.
`app_build/` est un clone bare — les agents travaillent dans le worktree `main/`.

## Prérequis

- [Claude Code](https://claude.ai/code) installé et configuré
- `gh` CLI installé et authentifié (`gh auth login`)
- Git >= 2.5

## Installation

```bash
bash scripts/init.sh
```

Le script initialise le dépôt orchestrateur, clone l'application en mode bare dans
`app_build/` (ou initialise un nouveau dépôt vide), et réinitialise `active.json`.

---

## Utilisation

### Démarrer un nouveau cycle

```
/startcycle "ton idée"
```

Exemples :
```
/startcycle "une app de gestion de tâches avec dark mode"
/startcycle "ajouter l'authentification OAuth"
/startcycle "endpoint d'export CSV"
```

Le mode est détecté automatiquement :
- `app_build/.git` absent → **greenfield** : scaffold complet
- `app_build/.git` présent → **existing** : Change Request ciblé

### Autres commandes

| Commande | Description |
|---|---|
| `/resume [feature_id]` | Reprend un pipeline interrompu à la bonne phase |
| `/status` | Affiche l'état de toutes les features dans `active.json` |
| `/clean [feature_id]` | Supprime worktrees et branches (toutes ou une feature) |

---

## Pipeline

```
/startcycle "idée"
      │
      ▼
  PM — Q&A itératif (1-2 questions à la fois)
      │
      ▼
  PM — Rédaction spec dans app_build/docs/{feature_id}/
      │
      ▼
  spec_checker  → vérifie la complétude
  spec_challenger → challenge les choix techniques
      │
      ▼
  PM — Révision + présentation pour approbation ("Go")
      │
      ▼
  Engineer  → crée feature/{id}, implémente, commit
      │
      ▼
  Tester    → tests unitaires/intégration/E2E, rapport
      │
      ▼
  Reviewer  → PR GitHub, review vs spec, merge ou blocage
      │
      ▼
  Doc Writer → fonctionnalites.md, specs.md, points_attention.md
```

---

## Structure du répertoire

```
.
├── .agents/
│   ├── agents.md                    ← index des 7 agents
│   ├── agents/                      ← définitions des rôles
│   │   ├── pm.md
│   │   ├── spec_checker.md
│   │   ├── spec_challenger.md
│   │   ├── engineer.md
│   │   ├── tester.md
│   │   ├── reviewer.md
│   │   └── doc_writer.md
│   ├── skills/                      ← actions atomiques (9 skills)
│   ├── workflows/
│   │   ├── startcycle.md            ← pipeline principal
│   │   └── sequential_roles.md     ← orchestration Engineer→Tester→Reviewer→DocWriter
│   └── state/
│       ├── active.json              ← état runtime (gitignored)
│       └── SCHEMA.md                ← documentation du schéma active.json
├── .claude/
│   ├── commands/                    ← /startcycle, /resume, /status, /clean
│   └── settings.json                ← permissions et hooks (versionné)
├── .gemini/
│   └── commands/startcycle.md
├── scripts/
│   ├── init.sh                      ← initialisation
│   └── clean.sh                     ← nettoyage des worktrees
├── CLAUDE.md → AGENTS.md            ← contexte orchestrateur (symlink)
├── GEMINI.md
└── README.md
```

---

## Suivi de l'état

```
/status
```

Ou en lisant directement `.agents/state/active.json` (voir `SCHEMA.md` pour le format).

Phases possibles : `spec_approved` · `engineer_done` · `tester_done` · `review_approved` · `review_failed` · `docs_written` · `merged`

## Nettoyage

```bash
# Via slash command (avec confirmation)
/clean <feature_id>

# Via script direct
bash scripts/clean.sh <feature_id>   # une feature
bash scripts/clean.sh                # toutes les features
```
