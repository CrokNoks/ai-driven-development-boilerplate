# Skill: Write Specs

## Objectif
Transformer une idée brute en spécification technique précise, après une phase de réflexion
collaborative avec l'utilisateur. Toute la documentation est versionnée dans `app_build/docs/`.

## Chemins
```
SPEC_DIR = app_build/docs/{FEATURE_ID}/
SPEC_FILE = app_build/docs/{FEATURE_ID}/Technical_Specification.md
```

## Instructions

### Phase 1 — Réflexion (avant d'écrire quoi que ce soit)

Ne commence PAS à rédiger la spec immédiatement. Engage d'abord une conversation avec l'utilisateur.

Analyse l'idée sous ces angles et pose les questions nécessaires :

**Problème & utilisateurs**
- Quel problème concret cette app résout-elle ?
- Qui sont les utilisateurs cibles ? (grand public, usage interne, développeurs…)

**Périmètre**
- Quelles sont les fonctionnalités indispensables pour un premier MVP ?
- Qu'est-ce qui est explicitement hors scope ?

**Contraintes techniques**
- Y a-t-il des contraintes de stack, d'hébergement, ou d'intégration ?
- Des préférences sur le langage ou le framework ?

**Critères de succès**
- Comment saura-t-on que la feature est "done" ? Quels sont les comportements attendus ?

Pose ces questions de façon conversationnelle — pas en liste exhaustive. Adapte selon ce que
l'utilisateur a déjà précisé. Si l'idée est claire sur un point, ne redemande pas.

Attends les réponses avant de continuer.

---

### Phase 2 — Rédaction de la spec

Une fois les réponses obtenues, dérive un `FEATURE_ID` court en snake_case (max 20 chars).
Exemple : "Mon App de Todo" → `todo_app`

Crée `app_build/docs/{FEATURE_ID}/Technical_Specification.md` :

```markdown
# Technical Specification — {NOM DU PROJET}

## Résumé
Deux ou trois phrases décrivant le projet, son objectif et ses utilisateurs cibles.

## Fonctionnalités (MVP)
Liste des fonctionnalités incluses dans le scope, avec une description courte pour chacune.

## Hors scope
Ce qui ne sera PAS implémenté dans cette version.

## Stack technique
- Langage / Runtime :
- Framework principal :
- Base de données :
- Autres dépendances notables :
Justification du choix (1-2 phrases).

## Architecture
Description de l'organisation des modules, de l'API si applicable, et du flux de données principal.

## Critères d'acceptance
Liste de conditions vérifiables qui définissent le "done" pour chaque fonctionnalité principale.
```

---

### Phase 3 — Documentation structurelle

Identifie quelles informations structurelles méritent d'être documentées séparément, et crée les
fichiers correspondants dans `app_build/docs/{FEATURE_ID}/` :

| Si le projet implique… | Créer… |
|---|---|
| Une API (REST, GraphQL…) | `api.md` — endpoints, méthodes, formats de requête/réponse |
| Un modèle de données | `data_model.md` — entités, champs, relations |
| Une architecture multi-couches | `architecture.md` — schéma des composants et leurs interactions |
| Des décisions techniques importantes | `decisions.md` — pourquoi ce choix plutôt qu'un autre (ADR léger) |

Ne crée que les fichiers pertinents. Un projet simple n'a pas besoin de tous ces fichiers.

---

### Phase 4 — Commit dans app_build/

Commite la documentation sur `main` avant que l'Engineer crée la branche feature :

```bash
cd app_build/
git checkout main
git add docs/{FEATURE_ID}/
git commit -m "docs({FEATURE_ID}): spec et documentation initiale"
```

---

### Phase 5 — Présentation dans le chat

Présente la spec directement dans la conversation :

```
---
**Spec — {NOM DU PROJET}** (`{FEATURE_ID}`)

**Stack** : {stack en une ligne}

**Fonctionnalités MVP** :
- {feature 1}
- {feature 2}
- …

**Hors scope** : {liste courte}

**Critères d'acceptance** :
- {critère 1}
- {critère 2}

**Docs générées** : {liste des fichiers créés dans docs/{FEATURE_ID}/}
---
Des ajustements ? Ou tape **"Go"** pour lancer le développement.
```

Ne dis pas "ouvre le fichier". Tout doit être lisible directement dans le chat.

---

### Phase 6 — Boucle de révision

Si l'utilisateur donne du feedback :
1. Identifie précisément ce qui change
2. Mets à jour les fichiers concernés dans `app_build/docs/{FEATURE_ID}/`
3. Commite les modifications : `git commit -m "docs({FEATURE_ID}): révision suite au feedback"`
4. Reprends la **Phase 5** avec la version mise à jour

Répète jusqu'à approbation explicite ("Go", "Ok", "C'est bon", "Approved", ou équivalent).

---

### Phase 7 — Handoff

Une fois approuvé, mets à jour `.agents/state/active.json` :

```json
{
  "features": {
    "{FEATURE_ID}": {
      "mode": "greenfield",
      "phase": "spec_approved",
      "spec_path": "docs/{FEATURE_ID}/Technical_Specification.md"
    }
  }
}
```

Annonce : **"Spec validée. Je passe la main à l'Engineer."**
