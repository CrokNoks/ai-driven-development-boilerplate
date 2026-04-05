# Skill: Write Bug Report

## Objectif

Collecter les informations nécessaires à la résolution d'un bug via un Q&A ciblé avec
l'utilisateur, puis produire un Bug Report précis qui guidera l'Engineer dans son diagnostic.

## Chemins

```
BUG_DIR  = app_build/docs/bugs/{BUG_ID}/
BUG_FILE = app_build/docs/bugs/{BUG_ID}/Bug_Report.md
```

> `BUG_ID` est dérivé en snake_case depuis la description du bug (max 20 chars).
> Exemple : "le login OAuth redirige vers une 404" → `login_oauth_redirect`

## Instructions

### Phase 1 — Explorer la codebase (silencieusement)

Avant d'engager la conversation, explore `app_build/` pour comprendre le contexte :

1. Structure et stack détectés (langage, framework, gestionnaire de dépendances)
2. Composants/modules susceptibles d'être affectés par le bug décrit
3. Tests existants liés au composant concerné
4. Tickets ou mentions du bug dans `app_build/docs/` (si présents)

---

### Phase 2 — Q&A ciblé avec l'utilisateur

**IMPORTANT : 1 à 2 questions à la fois.** Attends les réponses avant de continuer.

Présente d'abord ce que tu as compris de la codebase (2-3 lignes) et du bug décrit.

Sujets à couvrir au fil de la conversation :

**Reproduction**
- Quelles sont les étapes exactes pour reproduire le bug ?
- Le bug est-il reproductible systématiquement ou intermittent ?

**Comportement**
- Que se passe-t-il actuellement ? (message d'erreur, comportement observé)
- Que devrait-il se passer normalement ?

**Contexte**
- Dans quel environnement le bug a-t-il été constaté ? (dev, staging, production)
- Depuis quand le bug est-il présent ? (récent, toujours été là, après une modification)

**Impact**
- Combien d'utilisateurs sont impactés ? (tous, certains profils, cas spécifique)
- Est-ce bloquant ? (l'utilisateur ne peut pas continuer) ou dégradé ? (contournement possible)

Adapte les questions selon ce qui a déjà été précisé dans l'idée initiale.

---

### Phase 3 — Rédaction du Bug Report

Dérive le `BUG_ID` en snake_case (max 20 chars).

Crée `app_build/docs/bugs/{BUG_ID}/Bug_Report.md` :

```markdown
# Bug Report — {TITRE DU BUG}

## Résumé
Une phrase décrivant le bug et son impact.

## Environnement
- Stack : {langage, framework, version}
- Environnement : {dev / staging / production}
- Date de détection : {date ou "récent"}

## Étapes pour reproduire
1. {étape 1}
2. {étape 2}
3. …

## Comportement observé
{Ce qui se passe réellement — message d'erreur, valeur incorrecte, crash, etc.}

## Comportement attendu
{Ce qui devrait se passer.}

## Impact
- **Sévérité** : Critique / Majeur / Mineur
- **Utilisateurs impactés** : {tous / certains profils / cas spécifique}
- **Contournement disponible** : Oui / Non — {description si oui}

## Composant probable
{Module, fichier ou fonction suspecté d'être la source du bug.}

## Contexte additionnel
{Toute information utile : logs, screenshots décrits, commit récent suspect, etc.}
```

---

### Phase 4 — Commit dans app_build/

```bash
cd app_build/
git checkout main
git add docs/bugs/{BUG_ID}/
git commit -m "docs(bug/{BUG_ID}): bug report initial"
```

---

### Phase 5 — Présentation dans le chat

```
---
**Bug Report — {TITRE}** (`{BUG_ID}`)

**Sévérité** : {Critique / Majeur / Mineur}
**Composant suspect** : {module ou fichier}

**Reproduction** :
1. {étape 1}
2. {étape 2}

**Observé** : {comportement actuel}
**Attendu** : {comportement correct}

**Impact** : {utilisateurs impactés} — contournement : {Oui/Non}
---
Des précisions à ajouter ? Ou tape **"Go"** pour lancer le diagnostic.
```

---

### Phase 6 — Boucle de révision

Si l'utilisateur corrige ou complète :
1. Mets à jour `app_build/docs/bugs/{BUG_ID}/Bug_Report.md`
2. Commite : `git commit -m "docs(bug/{BUG_ID}): mise à jour suite au feedback"`
3. Reprends la Phase 5

Répète jusqu'à approbation explicite ("Go", "Ok", "C'est bon", ou équivalent).

---

### Phase 7 — Handoff

Une fois approuvé, mets à jour `.agents/state/active.json` :

```json
{
  "feature_id": "{BUG_ID}",
  "features": {
    "{BUG_ID}": {
      "type": "bugfix",
      "mode": "existing",
      "phase": "spec_approved",
      "codebase_dir": "app_build/main",
      "spec_path": "docs/bugs/{BUG_ID}/Bug_Report.md"
    }
  }
}
```

Annonce : **"Bug Report validé. Je passe la main à l'Engineer pour le diagnostic."**
