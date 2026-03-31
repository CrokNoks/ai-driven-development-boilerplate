# Skill: Write Docs

## Objectif

Lire le code implémenté et la spec associée, puis produire une documentation structurée en trois fichiers dans `app_build/docs/{FEATURE_ID}/`. Mettre à jour l'index global et s'assurer que le README racine est en place.

## Chemins

```
DOCS_DIR    = app_build/docs/{FEATURE_ID}/
FEAT_FILE   = app_build/docs/{FEATURE_ID}/fonctionnalites.md
SPECS_FILE  = app_build/docs/{FEATURE_ID}/specs.md
ATTN_FILE   = app_build/docs/{FEATURE_ID}/points_attention.md
INDEX_FILE  = app_build/docs/index.md
README_FILE = app_build/README.md
```

---

## Instructions

### Phase 1 — Lecture du contexte

Avant d'écrire quoi que ce soit, lis :

1. La spec : `app_build/docs/{FEATURE_ID}/Technical_Specification.md`
2. Le code source implémenté dans `app_build/` sur la branche courante
3. Les tests existants pour comprendre les comportements attendus et les cas limites

Identifie :
- Les fonctionnalités réellement implémentées (pas seulement spécifiées)
- Les choix techniques effectifs (stack, structure, patterns utilisés)
- Les comportements non-évidents, limitations ou dettes techniques visibles dans le code

---

### Phase 2 — Rédaction des trois fichiers

#### `fonctionnalites.md`

Documente **ce que fait la feature du point de vue utilisateur/produit**.

```markdown
# Fonctionnalités — {NOM DE LA FEATURE}

## Vue d'ensemble
Deux ou trois phrases décrivant la feature et sa valeur.

## {Fonctionnalité 1}
Description claire de ce que ça fait, comment l'utiliser, ce que ça produit.

## {Fonctionnalité 2}
…

## Ce qui n'est pas inclus
Liste courte des cas explicitement hors scope dans cette version.
```

#### `specs.md`

Documente **comment la feature est construite techniquement**.

```markdown
# Spécifications techniques — {NOM DE LA FEATURE}

## Stack
- Langage / Runtime : …
- Framework : …
- Dépendances clés : …

## Architecture
Description de l'organisation des modules, des couches, du flux de données.
Inclure un schéma ASCII si ça aide à la compréhension.

## API / Interface
Si applicable : endpoints, méthodes, formats de requête/réponse, contrats de types.

## Modèle de données
Si applicable : entités, champs, relations, contraintes.

## Configuration
Variables d'environnement, fichiers de config, valeurs par défaut.
```

#### `points_attention.md`

Documente **ce qu'un développeur doit savoir avant de toucher au code**.

```markdown
# Points d'attention — {NOM DE LA FEATURE}

## Comportements non-évidents
Liste des comportements implicites ou surprenants observés dans le code.

## Limitations connues
Ce qui ne fonctionne pas encore, les edge cases non gérés, les raccourcis pris.

## Dette technique
Code à refactorer, dépendances à migrer, décisions provisoires à revisiter.

## Risques opérationnels
Problèmes de performance potentiels, points de fragilité, couplages forts.

## Notes de mise à jour
Si cette feature modifie un comportement existant : ce qui change et pourquoi.
```

---

### Phase 3 — Mise à jour de l'index global

Ouvre (ou crée) `app_build/docs/index.md` et ajoute une entrée pour cette feature :

```markdown
# Documentation — {NOM DU PROJET}

Sommaire de toutes les features documentées.

---

## Features

| Feature | Fonctionnalités | Specs | Points d'attention |
|---|---|---|---|
| [{FEATURE_ID}](./{FEATURE_ID}/fonctionnalites.md) | [Fonctionnalités](./{FEATURE_ID}/fonctionnalites.md) | [Specs](./{FEATURE_ID}/specs.md) | [Points d'attention](./{FEATURE_ID}/points_attention.md) |
```

Si d'autres features sont déjà listées, ajoute simplement une nouvelle ligne dans le tableau — ne supprime rien.

---

### Phase 4 — Vérification du README racine

Vérifie que `app_build/README.md` existe et contient un lien vers `docs/index.md`.

Si le fichier n'existe pas ou ne contient pas ce lien, ajoute-le :

```markdown
## Documentation

La documentation complète est disponible dans [`docs/index.md`](docs/index.md).
```

Ne remplace pas un README existant — ajoute uniquement la section manquante.

---

### Phase 5 — Commit

```bash
cd app_build/
git add docs/{FEATURE_ID}/ docs/index.md README.md
git commit -m "docs({FEATURE_ID}): fonctionnalités, specs et points d'attention"
```

---

### Phase 6 — Mise à jour du statut

Mets à jour `.agents/state/active.json` :

```json
{
  "features": {
    "{FEATURE_ID}": {
      "phase": "docs_written",
      "docs": {
        "fonctionnalites": "docs/{FEATURE_ID}/fonctionnalites.md",
        "specs": "docs/{FEATURE_ID}/specs.md",
        "points_attention": "docs/{FEATURE_ID}/points_attention.md",
        "index": "docs/index.md"
      }
    }
  }
}
```

---

### Phase 7 — Présentation dans le chat

Annonce la fin du travail avec un résumé :

```
---
**Documentation écrite — {NOM DE LA FEATURE}** (`{FEATURE_ID}`)

**Fichiers générés** :
- `docs/{FEATURE_ID}/fonctionnalites.md` — {N} fonctionnalités documentées
- `docs/{FEATURE_ID}/specs.md` — stack, architecture{, API}{, modèle de données}
- `docs/{FEATURE_ID}/points_attention.md` — {N} points identifiés

**Index mis à jour** : `docs/index.md`

**Points d'attention notables** : {1-2 points importants à signaler explicitement}
---
```
