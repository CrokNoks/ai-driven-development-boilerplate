# Skill: Create Worktrees

## Objectif
Préparer les 3 worktrees isolés (Engineer, QA, DevOps) pour une feature donnée,
puis enregistrer son état dans le manifest de coordination.

## Prérequis
- La spec `production_artifacts/{FEATURE_ID}/Technical_Specification.md` doit exister
- `app_build/` doit être un dépôt Git **bare** (`git clone --bare` ou `git init --bare`)
  → voir la section "Initialiser app_build" dans le README

## Instructions

### Étape 1 — Extraire le FEATURE_ID
Lis `production_artifacts/{FEATURE_ID}/Technical_Specification.md` et confirme l'ID.
Si ce skill est appelé depuis `startcycle`, le FEATURE_ID est déjà fourni en paramètre.

### Étape 2 — Lire le mode depuis le manifest
Lis `.agents/state/active.json` → `features.{FEATURE_ID}.mode`
(`"greenfield"` ou `"existing"`)

### Étape 3 — Définir les variables
```
ORCHESTRATOR_PATH = répertoire courant de l'orchestrateur (chemin absolu)
APP_REPO_PATH     = {ORCHESTRATOR_PATH}/app_build
FEATURE_ID        = identifiant de la feature (snake_case, max 20 chars)

BRANCH_ENG        = feature/{FEATURE_ID}-impl
BRANCH_QA         = feature/{FEATURE_ID}-tests
BRANCH_DEV        = feature/{FEATURE_ID}-infra

# Chemins des worktrees, relatifs à APP_REPO_PATH
PATH_ENG          = {APP_REPO_PATH}/{FEATURE_ID}/engineer
PATH_QA           = {APP_REPO_PATH}/{FEATURE_ID}/qa
PATH_DEV          = {APP_REPO_PATH}/{FEATURE_ID}/devops

OUT_ENG           = .
OUT_QA            = tests/
OUT_DEV           = .
```

### Étape 4 — Créer les worktrees
`app_build/` est un dépôt bare — pas de `git checkout`, on passe directement
à `git worktree add` depuis l'intérieur du bare repo.

```bash
cd {APP_REPO_PATH}

git worktree add {FEATURE_ID}/engineer -b {BRANCH_ENG}
git worktree add {FEATURE_ID}/qa       -b {BRANCH_QA}
git worktree add {FEATURE_ID}/devops   -b {BRANCH_DEV}
```

### Étape 5 — Copier la spec dans chaque worktree
```bash
mkdir -p {PATH_ENG}/production_artifacts
mkdir -p {PATH_QA}/production_artifacts
mkdir -p {PATH_DEV}/production_artifacts

cp {REPO_PATH}/production_artifacts/{FEATURE_ID}/Technical_Specification.md {PATH_ENG}/production_artifacts/
cp {REPO_PATH}/production_artifacts/{FEATURE_ID}/Technical_Specification.md {PATH_QA}/production_artifacts/
cp {REPO_PATH}/production_artifacts/{FEATURE_ID}/Technical_Specification.md {PATH_DEV}/production_artifacts/
```

### Étape 6 — Injecter les fichiers de contexte depuis le template
Pour chaque rôle, copie `.agents/templates/worktree.md`, remplace les placeholders,
et écris le résultat **deux fois** à la racine du worktree :
- `CLAUDE.md` → lu par Claude Code
- `GEMINI.md` → lu par Gemini CLI

Les deux fichiers ont un contenu identique. Tout agent (Claude ou Gemini) trouvera ainsi son fichier de contexte.

#### Engineer
```
{{ROLE}}          → Full-Stack Engineer
{{BRANCH}}        → {BRANCH_ENG}
{{WORKTREE_PATH}} → {PATH_ENG}
{{REPO_PATH}}     → {REPO_PATH}
{{OUTPUT_DIR}}    → {OUT_ENG}
{{ROLE_KEY}}      → engineer
{{SKILL_FILE}}    → generate_code.md   (si mode=greenfield)
                    modify_code.md     (si mode=existing)
{{MISSION}}       → [greenfield] Implémente l'application complète dans ton worktree.
                    Publie `{REPO_PATH}/production_artifacts/{FEATURE_ID}/api_contract.md`
                    dès que les interfaces sont définies.
                    [existing] Lis le code existant avant toute modification.
                    Applique uniquement les changements décrits dans le Change Request.
```

#### QA
```
{{ROLE}}          → QA Engineer
{{BRANCH}}        → {BRANCH_QA}
{{WORKTREE_PATH}} → {PATH_QA}
{{REPO_PATH}}     → {REPO_PATH}
{{OUTPUT_DIR}}    → {OUT_QA}
{{ROLE_KEY}}      → qa
{{SKILL_FILE}}    → audit_code.md
{{MISSION}}       → [greenfield] Écris des tests complets (TDD) basés sur la spec
                    et `{REPO_PATH}/production_artifacts/{FEATURE_ID}/api_contract.md`
                    dès qu'il est disponible. Tes tests vont dans `tests/`.
                    [existing] Explore les tests existants, complète-les pour
                    couvrir le Change Request, détecte les régressions potentielles.
```

#### DevOps
```
{{ROLE}}          → DevOps Master
{{BRANCH}}        → {BRANCH_DEV}
{{WORKTREE_PATH}} → {PATH_DEV}
{{REPO_PATH}}     → {REPO_PATH}
{{OUTPUT_DIR}}    → {OUT_DEV}
{{ROLE_KEY}}      → devops
{{SKILL_FILE}}    → deploy_app.md
{{MISSION}}       → [greenfield] Crée Dockerfile, docker-compose.yml, .env.example,
                    Makefile à la racine de ton worktree. Basé sur la spec.
                    [existing] Inspecte la config existante et mets à jour uniquement
                    ce qui est impacté par le Change Request.
```

### Étape 7 — Mettre à jour le manifest
Ajoute ou mets à jour l'entrée `{FEATURE_ID}` dans `.agents/state/active.json` :

```json
{
  "features": {
    "{FEATURE_ID}": {
      "mode": "{MODE}",
      "phase": "parallel_execution",
      "spec_path": "production_artifacts/{FEATURE_ID}/Technical_Specification.md",
      "worktrees": {
        "engineer": {
          "branch": "{BRANCH_ENG}",
          "path": "app_build/{FEATURE_ID}/engineer",
          "status": "running",
          "output_dir": "."
        },
        "qa": {
          "branch": "{BRANCH_QA}",
          "path": "app_build/{FEATURE_ID}/qa",
          "status": "running",
          "output_dir": "tests/"
        },
        "devops": {
          "branch": "{BRANCH_DEV}",
          "path": "app_build/{FEATURE_ID}/devops",
          "status": "running",
          "output_dir": "."
        }
      }
    }
  }
}
```

**Important** : ne pas écraser les autres features déjà présentes dans `features`.
Fusionne uniquement l'entrée `{FEATURE_ID}`.

### Étape 8 — Confirmer
Affiche un récapitulatif des worktrees créés pour cette feature.
