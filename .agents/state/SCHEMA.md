# Schéma — active.json

Fichier de coordination runtime du pipeline. Mis à jour par chaque agent au fil des phases.
**Gitignored** — local uniquement, réinitialisé par `scripts/init.sh`.

## Structure complète

```json
{
  "mode": "greenfield | existing",
  "type": "feature | bugfix",
  "feature_id": "string — identifiant de la feature ou du bug en cours",
  "codebase_dir": "string — chemin relatif depuis REPO_PATH (ex: app_build/main)",
  "features": {
    "{FEATURE_ID}": {
      "type": "feature | bugfix",
      "mode": "greenfield | existing",
      "phase": "voir table des phases ci-dessous",
      "codebase_dir": "string — app_build/main",
      "spec_path": "string — chemin relatif depuis APP_BUILD_PATH vers le document de référence",
      "pr_url": "string (optionnel) — URL de la PR GitHub",
      "review_issues": ["string"],
      "roles": {
        "engineer":   { "status": "done | merged" },
        "tester":     { "status": "done | merged" },
        "reviewer":   { "status": "done | merged" },
        "doc_writer": { "status": "done | merged" }
      },
      "docs": {
        "fonctionnalites": "docs/{FEATURE_ID}/fonctionnalites.md",
        "specs":           "docs/{FEATURE_ID}/specs.md",
        "points_attention":"docs/{FEATURE_ID}/points_attention.md",
        "index":           "docs/index.md"
      }
    }
  }
}
```

### Valeurs de `spec_path` selon le type

| Type | Valeur de `spec_path` |
|---|---|
| `feature` (greenfield) | `docs/{FEATURE_ID}/Technical_Specification.md` |
| `feature` (existing) | `docs/{FEATURE_ID}/Technical_Specification.md` |
| `bugfix` | `docs/bugs/{BUG_ID}/Bug_Report.md` |

## Table des phases

| Phase | Déclenché par | Description |
|---|---|---|
| `spec_approved` | PM (`write_specs` / `write_change_spec` / `write_bug_report`) | Document de référence validé par l'utilisateur |
| `engineer_done` | Engineer (`generate_code` / `modify_code` / `fix_bug`) | Code implémenté/corrigé et commité |
| `tester_done` | Tester (`test_code`) | Tests écrits, exécutés, rapport généré |
| `review_approved` | Reviewer (`review_pr`) | PR approuvée et mergée sur main |
| `review_failed` | Reviewer (`review_pr`) | PR bloquée — problèmes dans `review_issues` |
| `docs_written` | Doc Writer (`write_docs`) ou orchestrateur (bugfix skip) | Documentation produite ou étape ignorée |
| `merged` | Changelog (`write_changelog`) | CHANGELOG.md mis à jour — feature/fix complet |

## Statuts des rôles

| Statut | Signification |
|---|---|
| `done` | Agent a terminé son travail sur la branche feature |
| `merged` | La branche a été mergée sur main |

## Règles de mise à jour

- Chaque agent **lit** `active.json` en début de tâche pour récupérer `FEATURE_ID` et `codebase_dir`
- Chaque agent **écrit** dans la clé `features[FEATURE_ID]` uniquement — jamais en dehors
- Le champ `phase` au niveau racine (`features[FEATURE_ID].phase`) est la source de vérité pour le routage dans `sequential_roles.md` et `/resume`
- `review_issues` n'est présent que si `phase = "review_failed"` — c'est une liste de strings décrivant chaque problème bloquant
