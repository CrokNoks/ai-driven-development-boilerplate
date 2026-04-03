# Skill: Write Change Spec

## Objectif
Analyser une codebase existante, clarifier la demande avec l'utilisateur, puis rédiger
un Change Request précis. Toute la documentation est versionnée dans `app_build/docs/`.
Ce skill remplace `write_specs.md` en mode `existing`.

## Chemins
```
SPEC_DIR  = app_build/docs/{FEATURE_ID}/
SPEC_FILE = app_build/docs/{FEATURE_ID}/Technical_Specification.md
```

## Instructions

### Phase 1 — Explorer la codebase (silencieusement)

Avant d'engager la conversation, explore `app_build/` pour te construire une image claire
de ce qui existe :

1. Structure du répertoire (2 niveaux)
2. Stack et framework utilisés
3. Fichiers d'entrée principaux
4. Conventions de nommage et patterns existants
5. Documentation existante dans `app_build/docs/` (si présente)
6. Tests existants (si présents)

---

### Phase 2 — Réflexion itérative avec l'utilisateur

Présente d'abord ce que tu as compris de la codebase en 3-4 lignes.
Ensuite, engage la conversation pour cadrer la demande.

**IMPORTANT : Procède par Q&A itératif.**
Pose **seulement 1 ou 2 questions** ciblées à la fois. Attends la réponse de l'utilisateur avant d'aborder les points suivants.

Sujets à clarifier au fil de la conversation :

**Périmètre**
- Quelles parties du code sont concernées par ce changement ?
- Qu'est-ce qui doit absolument rester intact ?

**Comportement attendu**
- Comment cette feature doit-elle se comporter du point de vue utilisateur ?
- Y a-t-il des cas limites à gérer en priorité ?

**Contraintes**
- Des contraintes de compatibilité ou de performance à respecter ?
- La feature doit-elle s'intégrer avec des systèmes externes ?

Adapte selon ce que l'utilisateur a déjà précisé. Attends les réponses avant de poser d'autres questions.

---

### Phase 3 — Rédaction du Change Request

Dérive un `FEATURE_ID` court en snake_case (max 20 chars).
Exemple : "Authentification OAuth" → `auth_oauth`

Crée `app_build/docs/{FEATURE_ID}/Technical_Specification.md` :

```markdown
# Change Request — {NOM DE LA FEATURE}

## Contexte
Brève description de la codebase existante et du stack détecté.

## Demande
Description précise du changement à apporter.

## Stack détecté
- Langage :
- Framework :
- Gestionnaire de dépendances :

## Périmètre des modifications

### Fichiers à créer
| Fichier | Description |
|---|---|

### Fichiers à modifier
| Fichier | Modification |
|---|---|

### Fichiers à NE PAS toucher
| Fichier | Raison |
|---|---|

## Interfaces et contrats
Nouvelles API, fonctions ou types à introduire.

## Critères d'acceptance
Liste de conditions vérifiables définissant le "done".

## Risques de régression
Parties du code existant potentiellement affectées indirectement.
```

---

### Phase 4 — Mise à jour de la documentation structurelle

Identifie ce que ce changement impacte au niveau structurel, et mets à jour ou crée les fichiers
correspondants dans `app_build/docs/` :

| Si la feature impacte… | Mettre à jour… |
|---|---|
| Des endpoints ou contrats API | `docs/api.md` (global) ou `docs/{FEATURE_ID}/api.md` (nouveau) |
| Le modèle de données | `docs/data_model.md` (global) ou `docs/{FEATURE_ID}/data_model.md` |
| L'architecture générale | `docs/architecture.md` |
| Des décisions techniques importantes | `docs/{FEATURE_ID}/decisions.md` |

Règle : si le fichier global existe déjà, ajoute une section pour cette feature.
Si la feature introduit quelque chose de vraiment nouveau, crée un fichier dédié.

---

### Phase 5 — Commit dans app_build/

```bash
cd app_build/
git checkout main
git add docs/{FEATURE_ID}/ docs/api.md docs/data_model.md  # selon ce qui a changé
git commit -m "docs({FEATURE_ID}): change request et mise à jour de la documentation"
```

---

### Phase 6 — Présentation dans le chat

```
---
**Change Request — {NOM DE LA FEATURE}** (`{FEATURE_ID}`)

**Codebase** : {stack détecté en une ligne}

**Ce qui change** :
- {fichier ou module 1} → {modification}
- {fichier ou module 2} → {modification}
- …

**Ce qui ne change pas** : {liste courte}

**Critères d'acceptance** :
- {critère 1}
- {critère 2}

**Risques de régression** : {risques identifiés ou "aucun identifié"}

**Docs mises à jour** : {liste des fichiers créés/modifiés dans docs/}
---
Des ajustements ? Ou tape **"Go"** pour lancer le développement.
```

---

### Phase 7 — Boucle de révision

Si l'utilisateur donne du feedback :
1. Identifie précisément ce qui change
2. Mets à jour les fichiers concernés dans `app_build/docs/`
3. Commite : `git commit -m "docs({FEATURE_ID}): révision suite au feedback"`
4. Reprends la **Phase 6**

Répète jusqu'à approbation explicite ("Go", "Ok", "C'est bon", "Approved", ou équivalent).

---

### Phase 8 — Handoff

Une fois approuvé, mets à jour `.agents/state/active.json` :

```json
{
  "features": {
    "{FEATURE_ID}": {
      "mode": "existing",
      "phase": "spec_approved",
      "spec_path": "docs/{FEATURE_ID}/Technical_Specification.md"
    }
  }
}
```

Annonce : **"Change Request validé. Je passe la main à l'Engineer."**
