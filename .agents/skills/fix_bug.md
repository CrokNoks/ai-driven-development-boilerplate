# Skill: Fix Bug

## Objectif

Diagnostiquer la cause racine d'un bug à partir du Bug Report, appliquer un correctif
minimal et ciblé, et vérifier qu'il n'introduit pas de régression.

## Règles de base

- **Lire avant de toucher** : ne jamais modifier un fichier sans l'avoir lu en entier
- **Fix minimal** : corriger exactement ce qui est cassé, ne pas refactoriser autour
- **Cause racine, pas symptôme** : si le bug visible est causé par un problème plus profond,
  corriger la cause, pas l'effet
- **Zéro régression** : les tests existants doivent continuer à passer

## Instructions

### Étape 1 — Créer la branche fix

```bash
cd {APP_BUILD_PATH}
git checkout main
git pull
git checkout -b fix/{BUG_ID}
```

### Étape 2 — Lire le Bug Report

Ouvre `{APP_BUILD_PATH}/docs/bugs/{BUG_ID}/Bug_Report.md` et note :
- Les étapes de reproduction
- Le composant suspect
- Le comportement attendu vs observé
- La sévérité

Lis également les docs existantes en lien avec le composant suspect :
`app_build/docs/` (api.md, architecture.md, data_model.md si pertinents).

### Étape 3 — Diagnostic de la cause racine

1. Identifie les fichiers candidats à partir du "Composant probable" dans le Bug Report
2. Lis ces fichiers en entier
3. Trace le flux d'exécution correspondant aux étapes de reproduction
4. Identifie l'endroit exact où le comportement dévie de l'attendu
5. Formule une hypothèse de cause racine **avant** de commencer à modifier du code

Si la cause ne se trouve pas dans le composant suspect, élargis la recherche aux
dépendances directes (imports, fonctions appelées, middlewares).

### Étape 4 — Appliquer le correctif

1. Modifie uniquement les lignes/fonctions responsables du bug
2. Respecte le style de code existant (indentation, nommage, patterns)
3. Ne pas profiter du fix pour refactoriser du code adjacent
4. Vérifie que le fix répond aux 3 critères :
   - Le bug décrit ne peut plus se reproduire
   - Le comportement attendu est bien celui du Bug Report
   - Aucun autre comportement n'est modifié par le changement

### Étape 5 — Valider le fix

**Installer les dépendances** si nécessaire :
```bash
npm install 2>/dev/null || pnpm install 2>/dev/null || pip install -r requirements.txt 2>/dev/null || true
```

**Compiler / vérifier la syntaxe** :
```bash
npx tsc --noEmit 2>/dev/null || go build ./... 2>/dev/null || cargo check 2>/dev/null || true
```

**Linter** :
```bash
npm run lint 2>/dev/null || true
```

**Exécuter les tests existants** (pour détecter les régressions) :
```bash
npm test 2>/dev/null || pytest 2>/dev/null || go test ./... 2>/dev/null || cargo test 2>/dev/null || true
```

**Vérifier l'absence de secrets hardcodés** dans les fichiers modifiés :
```bash
git diff --name-only HEAD | xargs grep -lnE "(API_KEY|SECRET|PASSWORD|TOKEN)\s*=\s*[\"'][^\"']{8,}" 2>/dev/null || true
```

Si des tests échouent : analyse si c'est dû au fix ou à une régression.
- Si régression introduite par le fix → corrige avant de commiter (max 1 tentative)
- Si tests préexistants échouaient déjà → note-le dans le commit message

### Étape 6 — Commiter

```bash
cd {APP_BUILD_PATH}
git add .
git commit -m "fix({BUG_ID}): <description courte de la cause et du correctif>"
```

Le message de commit doit mentionner **la cause** (pas juste "fix bug"), ex :
`fix(login_oauth): corrige la redirection manquante après callback OAuth`

### Étape 7 — Mettre à jour le manifest

Dans `{REPO_PATH}/.agents/state/active.json` :

```json
"features": {
  "{BUG_ID}": {
    "phase": "engineer_done",
    "roles": {
      "engineer": { "status": "done" }
    }
  }
}
```
