# Skill: Check Spec Completeness

## Objectif
Analyser la `Technical_Specification.md` (ou Change Request) pour identifier les manques fonctionnels, les scénarios non couverts et les cas limites oubliés.

## Instructions

### 1. Analyse exhaustive
Parcours la spécification et cherche :
- **Scénarios d'erreur** : Que se passe-t-il si une API échoue ? Si l'utilisateur saisit des données invalides ?
- **Cas limites (Edge cases)** : Listes vides, valeurs nulles, dépassements de limites, permissions manquantes.
- **Cycle de vie** : La suppression/mise à jour des données est-elle prévue ?
- **Cohérence** : Les fonctionnalités MVP permettent-elles réellement d'atteindre l'objectif décrit ?

### 2. Feedback ciblé
Rédige un message court (max 5-6 points) sous forme de questions ou d'observations :
"Il manque le cas où..."
"Comment gère-t-on..."

### 3. Publication
Poste ton feedback directement dans le chat après le brouillon du PM.
Format :
---
**🔍 Completeness Check (@spec_checker)**
- [Point 1]
- [Point 2]
...
---
