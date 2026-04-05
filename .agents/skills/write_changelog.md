# Skill: Write Changelog

## Objectif

Après le merge de la PR, créer ou mettre à jour `CHANGELOG.md` dans `app_build/`
avec une entrée structurée pour la feature livrée.

## Chemins

```
CHANGELOG_FILE = {APP_BUILD_PATH}/CHANGELOG.md
```

---

## Instructions

### Étape 1 — Lire le contexte

Lis les sources suivantes :
1. `{REPO_PATH}/.agents/state/active.json` → récupère `FEATURE_ID`, `pr_url`, `mode`
2. `{APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md` → section Résumé et Fonctionnalités

---

### Étape 2 — Préparer l'entrée changelog

Dérive :
- **NOM** : titre court de la feature extrait de la spec (1-5 mots)
- **TYPE** : `Added` (greenfield ou nouvelle fonctionnalité) / `Changed` (modification) / `Fixed` (correction)
- **LISTE** : une ligne par fonctionnalité MVP listée dans la spec

Format d'entrée :

```markdown
## [Unreleased]

### {TYPE} — {NOM DE LA FEATURE}

- {fonctionnalité 1 extraite de la spec}
- {fonctionnalité 2 extraite de la spec}
- …

> PR : {pr_url} · Feature : `{FEATURE_ID}`
```

---

### Étape 3 — Créer ou mettre à jour CHANGELOG.md

**Si `CHANGELOG.md` n'existe pas :**

Crée-le avec ce contenu :

```markdown
# Changelog

Toutes les évolutions notables de ce projet sont documentées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/).

---

{entrée de la feature}
```

**Si `CHANGELOG.md` existe déjà :**

Insère la nouvelle entrée **en haut du fichier**, juste après le header (avant la première entrée `## `).
Ne modifie pas les entrées existantes.

---

### Étape 4 — Commiter

```bash
cd {APP_BUILD_PATH}
git add CHANGELOG.md
git commit -m "docs(changelog): {FEATURE_ID}"
```

---

### Étape 5 — Mettre à jour le manifest

Dans `{REPO_PATH}/.agents/state/active.json` :

```json
{
  "features": {
    "{FEATURE_ID}": {
      "phase": "merged"
    }
  }
}
```

---

### Étape 6 — Annoncer dans le chat

```
---
**Changelog mis à jour** — `{FEATURE_ID}`

**Entrée ajoutée** : {TYPE} — {NOM DE LA FEATURE}
**Fichier** : CHANGELOG.md
**Phase finale** : merged ✅
---
```
