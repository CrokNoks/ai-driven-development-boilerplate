---
AGENT BRIEFING — FICHIER CRITIQUE, NE PAS SUPPRIMER NI MODIFIER
---

# Contexte de travail

Tu es un agent IA travaillant dans un **worktree Git isolé**. Ce fichier fait office de
source de vérité absolue sur ton contexte. En cas de doute, relis-le.

## Ton identité
- **Rôle** : {{ROLE}}
- **Branche Git** : {{BRANCH}}

## Tes chemins
- **Ton répertoire de travail (worktree)** : {{WORKTREE_PATH}}  ← tu travailles ICI
- **Repo principal** : {{REPO_PATH}}
- **Spec / Change Request (lecture seule)** : {{WORKTREE_PATH}}/production_artifacts/Technical_Specification.md
- **Contrat API (lecture seule, peut ne pas exister encore)** : {{REPO_PATH}}/production_artifacts/api_contract.md
- **Ton répertoire de sortie** : {{WORKTREE_PATH}}/{{OUTPUT_DIR}}
- **Manifest de coordination** : {{REPO_PATH}}/.agents/state/active.json

## Ta mission
{{MISSION}}

## Règles ABSOLUES
1. Tu travailles UNIQUEMENT dans `{{WORKTREE_PATH}}`
2. Tu ne changes JAMAIS de branche Git (`git checkout` est interdit)
3. Tu ne modifies AUCUN fichier en dehors de `{{WORKTREE_PATH}}`
4. Tu lis la spec depuis le repo principal (lecture seule, ne jamais l'écraser)
5. Tous tes commits se font sur ta branche : `{{BRANCH}}`
6. Quand tu as terminé, tu mets à jour le manifest de coordination :
   - Fichier : `{{REPO_PATH}}/.agents/state/active.json`
   - Champ à mettre à jour : `worktrees.{{ROLE_KEY}}.status` → `"done"`

## Skill à exécuter

Cherche le skill dans cet ordre de priorité :

1. **Local (codebase)** : `{{WORKTREE_PATH}}/.agents/skills/{{SKILL_FILE}}`
   → s'il existe, il est spécifique à ce projet et prend la priorité
2. **Générique (orchestrateur)** : `{{REPO_PATH}}/.agents/skills/{{SKILL_FILE}}`
   → fallback universel

Lis et exécute le premier trouvé.
