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
- Si des tests échouent à cause d'un **problème dans le test lui-même** : corrige et relance.
- Si des tests échouent à cause d'un **bug dans l'implémentation** : escalade vers l'Engineer
  (voir Phase 5.5 ci-dessous).

### Phase 5.5 — Escalade vers l'Engineer (si nécessaire)

Si des bugs bloquent le bon déroulement des tests, tu peux faire appel à l'Engineer.

Lance un sous-agent avec le prompt suivant :

```
Tu es un agent IA jouant le rôle de Full-Stack Engineer.
Ton répertoire de travail est : {APP_BUILD_PATH}
Branche courante : feature/{FEATURE_ID}
La spec se trouve dans : {APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md
Le manifest de coordination est : {REPO_PATH}/.agents/state/active.json

Le Tester a identifié les bugs suivants qui empêchent les tests de passer :
{LISTE DES BUGS}

Corrige uniquement ces bugs dans l'implémentation. Ne modifie pas les fichiers de tests.
Commite tes corrections : git commit -m "fix({FEATURE_ID}): corrections suite aux retours du Tester"
```

Attends que l'Engineer ait terminé, puis **relance les tests** (retour à l'Étape 5).

Limite : maximum **2 allers-retours** avec l'Engineer. Si les tests échouent encore après 2 cycles,
note les problèmes restants dans le rapport et continue.

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
