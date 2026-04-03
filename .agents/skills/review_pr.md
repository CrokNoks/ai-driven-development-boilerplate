# Skill: Review PR

## Objectif
Créer une Pull Request GitHub depuis la branche feature fusionnée vers `main` dans le dépôt
`app_build/`, la relire en profondeur, et la valider ou la rejeter selon les standards du projet.

## Prérequis
- `FEATURE_ID` fourni en paramètre
- La phase de la feature dans `active.json` est `"tester_done"`
- Le dépôt `app_build/` est un dépôt GitHub (remote `origin` configuré)
- `gh` CLI est installé et authentifié (`gh auth status`)

## Instructions

### Étape 1 — Lire la spec et le contexte
Lis les fichiers suivants (lecture seule) :
- `{APP_BUILD_PATH}/docs/{FEATURE_ID}/Technical_Specification.md` — la spec approuvée
- `{APP_BUILD_PATH}/docs/{FEATURE_ID}/` — toute la documentation de la feature
- `.agents/state/active.json` — pour récupérer `FEATURE_ID`, `mode` et les chemins

Extrais :
- Les **fonctionnalités attendues** (section "Functional Requirements" ou équivalent)
- Les **critères d'acceptation** (section "Acceptance Criteria" ou équivalent)
- La **stack technique** retenue

### Étape 2 — Vérifier l'état de la branche
Depuis `app_build/` :
```bash
cd {APP_REPO_PATH}
git log main..feature/{FEATURE_ID} --oneline
git diff main..feature/{FEATURE_ID} --stat
```

Si la branche `feature/{FEATURE_ID}` n'existe pas ou n'a pas de commits, **arrête-toi** et informe l'utilisateur.

### Étape 3 — Créer la Pull Request
Depuis `app_build/`, utilise `gh` pour créer la PR :
```bash
cd {APP_REPO_PATH}
gh pr create \
  --base main \
  --head feature/{FEATURE_ID} \
  --title "feat({FEATURE_ID}): {titre court extrait de la spec}" \
  --body "$(cat <<'EOF'
## Résumé
{résumé en 2-3 phrases extrait de la spec}

## Fonctionnalités implémentées
{liste des fonctionnalités de la spec}

## Critères d'acceptation
{liste des critères d'acceptation de la spec}

## Agents impliqués
- Engineer: implémentation (`feature/{FEATURE_ID}`)
- Tester: suite de tests (`feature/{FEATURE_ID}`)

🤖 Générée automatiquement par le pipeline Autonomous AI Developer
EOF
)"
```

Note l'URL de la PR retournée par `gh pr create`.

### Étape 4 — Lire le diff complet
Récupère le diff complet pour la review :
```bash
cd {APP_REPO_PATH}
git diff main..feature/{FEATURE_ID}
```

Lis le diff en entier. Pour chaque fichier modifié, identifie sa fonction dans le projet.

### Étape 5 — Review selon les standards

Vérifie les points suivants et note les résultats (✅ OK / ⚠️ avertissement / ❌ bloquant) :

**Vérification de l'Implémentation (vs. Plan Approved)**
- [ ] **Fidélité au Plan** : Le code implémente-t-il exactement ce qui a été défini dans `Technical_Specification.md` ?
- [ ] **Dérive de Scope** : Y a-t-il du code superflu non demandé (gold plating) ?
- [ ] **Fonctionnalités manquantes** : Tous les points du MVP sont-ils couverts ?
- [ ] **Respect des Contrats** : Les signatures d'API, structures de données et choix de stack sont-ils ceux du plan ?

**Qualité du code**
- [ ] Pas de fichiers de debug, de console.log non intentionnels, ni de clés API en dur
- [ ] Les dépendances déclarées (`package.json`, `requirements.txt`, etc.) correspondent aux imports utilisés
- [ ] Pas de code mort ou de TODO non résolus bloquants

**Tests**
- [ ] Des fichiers de tests sont présents et fonctionnels (produits par QA/Tester)
- [ ] Les tests couvrent les cas nominaux et les critères d'acceptation de la spec

### Étape 6 — Décision

**Si tous les points sont ✅ ou ⚠️ (aucun ❌) :**

Approuve et merge la PR :
```bash
cd {APP_REPO_PATH}
gh pr review --approve --body "Implémentation fidèle à la spécification technique. Review automatique validée par l'agent Reviewer. ✅"
gh pr merge --merge --subject "feat({FEATURE_ID}): merge to main after review"
```

Met à jour `active.json` :
```json
"phase": "review_approved",
"pr_url": "{URL_PR}"
```

Informe l'utilisateur : la PR est mergée sur `main`, le déploiement peut commencer.

---

**Si au moins un point est ❌ (problème bloquant) :**

Poste un commentaire de review détaillé :
```bash
cd {APP_REPO_PATH}
gh pr review --request-changes --body "{description précise de chaque problème bloquant avec les fichiers et lignes concernés}"
```

Met à jour `active.json` :
```json
"phase": "review_failed",
"pr_url": "{URL_PR}",
"review_issues": ["{liste des problèmes bloquants}"]
```

Informe l'utilisateur des problèmes trouvés et demande comment procéder.
