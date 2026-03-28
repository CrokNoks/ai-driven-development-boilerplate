# Autonomous AI Developer Pipeline

Ce projet est un **orchestrateur** multi-agents (Claude Code) qui pilote le développement
d'une application. Les agents travaillent en parallèle sur des branches Git isolées via
des worktrees, à l'intérieur d'un dépôt applicatif séparé (`app_build/`).

## Compatibilité

| Fonctionnalité | Claude Code | Gemini CLI |
|---|---|---|
| Fichier de contexte projet | `CLAUDE.md` | `GEMINI.md` |
| Slash command `/startcycle` | `.claude/commands/` | `.gemini/commands/` |
| Contexte worktree | `CLAUDE.md` injecté | `GEMINI.md` injecté |
| Skills `.agents/` | ✅ | ✅ |
| Scripts `scripts/` | ✅ | ✅ |

Les deux outils peuvent travailler sur le même projet sans conflit.

## Deux dépôts distincts

```
orchestrateur/      ← ce dépôt (workflows, agents, specs)
app_build/          ← dépôt applicatif séparé (le code produit)
```

Les worktrees des agents sont créés dans `app_build/`, pas dans l'orchestrateur.

## Prérequis

- [Claude Code](https://claude.ai/code) installé et configuré
- Git >= 2.5 (pour le support des worktrees)

## Installation

### Script d'initialisation

```bash
bash scripts/init.sh
```

Le script :
1. Initialise le dépôt Git de l'orchestrateur si nécessaire
2. Demande l'URL du dépôt applicatif à cloner
3. Clone en mode **bare** dans `app_build/` (ou initialise un nouveau dépôt bare si aucune URL n'est fournie)
4. Réinitialise le manifest `.agents/state/active.json`

Si `app_build/` existe déjà, le script propose de le réinitialiser après confirmation.

---

## Initialiser app_build manuellement

`app_build/` utilise un **clone bare** — Git y stocke uniquement ses internals,
sans fichiers de travail. Les worktrees des agents sont ainsi les seuls répertoires
visibles, sans mélange avec le code de `main`.

### Avec un dépôt existant

```bash
git clone --bare <url-du-depot> app_build
```

### Pour un nouveau projet

```bash
git init --bare app_build
```

L'Engineer créera le premier commit depuis son worktree lors du scaffold.

## Démarrer un cycle de développement

```
/startcycle <ton idée>
```

Exemples :
```
/startcycle "une app de gestion de tâches avec authentification et dark mode"
/startcycle "ajouter l'authentification OAuth"
/startcycle "endpoint d'export CSV"
```

Le mode est **détecté automatiquement** :
- `app_build/.git` absent → **greenfield** : l'Engineer scaffolde l'app complète
- `app_build/.git` présent → **existing** : le PM analyse le code existant et rédige
  un Change Request ciblé (quoi créer, quoi modifier, quoi ne pas toucher)

---

Le pipeline se déroule en deux phases :

### Phase 1 — Spécification (interactive)

Le PM rédige la spec dans `production_artifacts/{feature_id}/Technical_Specification.md`.
Tu peux ouvrir ce fichier, ajouter des commentaires, et demander des révisions.
Tape **"Approved"** dans le chat pour valider.

### Phase 2 — Développement parallèle (automatique)

Trois agents sont lancés simultanément dans `app_build/`, chacun sur sa propre branche :

| Agent | Worktree | Branche |
|---|---|---|
| Engineer | `app_build/{id}/engineer/` | `feature/{id}-impl` |
| QA | `app_build/{id}/qa/` | `feature/{id}-tests` |
| DevOps | `app_build/{id}/devops/` | `feature/{id}-infra` |

Plusieurs features peuvent tourner simultanément — chacune a son propre namespace
dans `app_build/` et son entrée dans `.agents/state/active.json`.

Une fois les trois terminés, l'orchestrateur merge les branches dans `app_build/`
et supprime les worktrees.

## Structure du répertoire

```
.                               ← orchestrateur (ce dépôt)
├── app_build/                  ← dépôt bare (pas de fichiers de travail)
│   ├── HEAD, config, objects/  ← internals Git uniquement
│   └── {feature_id}/           # Worktrees créés au runtime
│       ├── engineer/           ← fichiers app de l'Engineer
│       ├── qa/                 ← fichiers app du QA
│       └── devops/             ← fichiers app du DevOps
├── production_artifacts/
│   └── {feature_id}/
│       ├── Technical_Specification.md  # Spec validée par le PM
│       └── api_contract.md             # Contrat d'interface (publié par l'Engineer)
├── .agents/
│   ├── agents.md               # Définitions des rôles
│   ├── skills/                 # Actions atomiques par rôle
│   ├── workflows/              # Séquences d'orchestration
│   ├── templates/              # Template CLAUDE.md pour les worktrees
│   └── state/active.json       # Manifest de coordination runtime
├── scripts/
│   ├── init.sh                 # Initialisation du dépôt et de app_build/
│   └── clean.sh                # Nettoyage des worktrees (feature ou toutes)
├── .claude/
│   └── commands/startcycle.md  # Slash command /startcycle pour Claude Code
├── .gemini/
│   └── commands/startcycle.md  # Slash command /startcycle pour Gemini CLI
├── CLAUDE.md                   # Contexte projet pour Claude Code
├── GEMINI.md                   # Contexte projet pour Gemini CLI
└── README.md
```

## Lancer l'application après le merge

Après merge, les worktrees sont supprimés. Le code final se trouve sur la branche
`feature/{id}` dans le dépôt bare `app_build/`.

Pour accéder aux fichiers, crée un worktree de consultation :

```bash
cd app_build
git worktree add ../release feature/{id}
cd ../release
```

### Détecter le stack

```bash
ls package.json      # Node
ls requirements.txt  # Python
ls go.mod            # Go
```

### Installer les dépendances et lancer

```bash
npm install && npm run dev                            # Node
pip install -r requirements.txt && python app.py     # Python
go mod download && go run .                           # Go
```

### Via Docker (config générée par le DevOps)

```bash
docker compose up
```

## Suivre l'état des agents

Le fichier `.agents/state/active.json` reflète l'état en temps réel :

```json
{
  "features": {
    "todo_app": {
      "phase": "parallel_execution",
      "worktrees": {
        "engineer": { "status": "done" },
        "qa":       { "status": "running" },
        "devops":   { "status": "running" }
      }
    },
    "auth_oauth": {
      "phase": "parallel_execution",
      "worktrees": {
        "engineer": { "status": "running" },
        "qa":       { "status": "running" },
        "devops":   { "status": "idle" }
      }
    }
  }
}
```

Statuts possibles : `idle` · `running` · `done` · `merged` · `error`

## Nettoyage des worktrees

Le nettoyage est **automatique** quand le merge réussit (`merge_roles.md` supprime
les worktrees en fin de pipeline). En cas d'erreur ou d'interruption, utilise le script :

```bash
# Nettoyer une feature spécifique
bash scripts/clean.sh <feature_id>

# Nettoyer toutes les features du manifest
bash scripts/clean.sh
```

Le script supprime proprement les worktrees enregistrés dans le bare repo
(`git worktree remove`), purge les orphelins (`git worktree prune`), supprime
les branches et met à jour `active.json`.

## Résoudre un problème

**Un agent est bloqué (`error`) :**
Lis son fichier de contexte dans `app_build/{id}/{role}/` (`CLAUDE.md` ou `GEMINI.md`)
pour comprendre son contexte, puis ouvre une session dans ce répertoire pour déboguer.
Une fois résolu, relance `/startcycle`.

**Repartir de zéro sur une feature :**
```bash
bash scripts/clean.sh <feature_id>
```
