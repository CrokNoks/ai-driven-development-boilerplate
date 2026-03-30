# Skill: Test Code

## Objectif
Créer et exécuter une suite de tests complète pour valider l'implémentation de la feature
avant la review.

## Règles de base
- **Répertoire de travail** : `app_build/` sur la branche `feature/{FEATURE_ID}`
- **Lecture seule** : `production_artifacts/Technical_Specification.md` et le code existant
- **Écriture** : fichiers de tests dans `app_build/tests/`

## Instructions

### Étape 1 — Se positionner sur la branche feature
```bash
cd {APP_BUILD_PATH}
git checkout feature/{FEATURE_ID}
```

### Étape 2 — Lire la spec et l'implémentation
Lis `{APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md` ainsi que les autres
fichiers de documentation dans `{APP_BUILD_PATH}/docs/{FEATURE_ID}/`.
Explore l'ensemble du code dans `app_build/` pour comprendre l'implémentation.

### Étape 3 — Identifier les chemins critiques
Dresse une liste des comportements à tester :
- Cas nominaux (happy path)
- Cas limites et edge cases décrits dans la spec
- Cas d'erreur (inputs invalides, ressources manquantes, etc.)
- Points d'intégration entre composants

### Étape 4 — Écrire les tests
Crée les fichiers de tests dans `tests/` en suivant les conventions du projet
(ou les conventions standards du langage si le projet n'en a pas).

Types de tests selon la nature de l'app :
- **Unitaires** : chaque fonction/module isolé
- **Intégration** : interactions entre composants
- **E2E** : flux utilisateur complets si applicable

Nomme les tests de façon explicite pour qu'un lecteur comprenne ce qui est testé sans lire le code.

### Étape 5 — Exécuter les tests
Lance la suite de tests et note les résultats.
- Si des tests échouent à cause d'un **bug dans l'implémentation** : note-le dans le rapport,
  ne modifie pas l'implémentation (c'est au Reviewer de décider).
- Si des tests échouent à cause d'un **problème dans le test lui-même** : corrige et relance.

### Étape 6 — Générer le rapport
Crée `tests/TEST_REPORT.md` :
```markdown
# Test Report — {FEATURE_ID}

## Résumé
- Total : X tests
- Passés : X
- Échoués : X
- Skipped : X

## Tests échoués
[liste des tests qui échouent avec le message d'erreur — vide si tout passe]

## Observations
[bugs ou comportements suspects détectés dans l'implémentation]
```

### Étape 7 — Commiter
```bash
cd {APP_BUILD_PATH}
git add tests/
git commit -m "test({FEATURE_ID}): suite de tests par l'agent Tester"
```

### Étape 8 — Mettre à jour le manifest
Dans `{REPO_PATH}/.agents/state/active.json` :
```json
"features": {
  "{FEATURE_ID}": {
    "phase": "tester_done",
    "roles": {
      "tester": { "status": "done" }
    }
  }
}
```
