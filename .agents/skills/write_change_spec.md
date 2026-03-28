# Skill: Write Change Spec

## Objectif
Analyser une codebase existante et rédiger un **Change Request** précis à partir
d'une demande de feature. Ce skill remplace `write_specs.md` en mode `--existing`.

## Différence avec write_specs.md
`write_specs.md` part de zéro et conçoit une architecture complète.
Ce skill part du code existant et définit **uniquement** ce qui doit changer.

## Prérequis
- `CODEBASE_DIR` : sous-répertoire contenant la codebase (fourni via active.json)
- La codebase est versionnée sous Git

## Instructions

### Étape 1 — Explorer la codebase
Avant d'écrire une seule ligne de spec, comprends ce qui existe :

1. Liste la structure du répertoire `{CODEBASE_DIR}/` (2 niveaux de profondeur)
2. Identifie le stack et le framework utilisé
3. Repère les fichiers d'entrée principaux (ex: `main.py`, `index.ts`, `app.js`)
4. Identifie les conventions de nommage, l'organisation des modules, les patterns existants
5. Lis les tests existants (si présents) pour comprendre les patterns de test utilisés

### Étape 2 — Rédiger le Change Request
Dérive un `FEATURE_ID` court en snake_case (max 20 chars) depuis le nom de la feature.
Exemple : "Authentification OAuth" → `auth_oauth`

Crée `production_artifacts/{FEATURE_ID}/Technical_Specification.md` avec la structure suivante :

```markdown
# Change Request : {NOM_FEATURE}

## Contexte
Brève description de la codebase existante et du stack détecté.

## Demande
Description précise de la feature ou du changement demandé.

## Stack détecté
- Langage : ...
- Framework : ...
- Gestionnaire de dépendances : ...
- Répertoire codebase : {CODEBASE_DIR}/

## Périmètre des modifications

### Fichiers à créer
| Fichier | Description |
|---|---|
| `{CODEBASE_DIR}/...` | ... |

### Fichiers à modifier
| Fichier | Modification |
|---|---|
| `{CODEBASE_DIR}/...` | ... |

### Fichiers à NE PAS toucher
| Fichier | Raison |
|---|---|
| `{CODEBASE_DIR}/...` | ... |

## Interfaces et contrats
Description des nouvelles API / fonctions / types à introduire.
(Sera publié dans `production_artifacts/api_contract.md` par l'Engineer)

## Critères d'acceptance
Liste de conditions vérifiables qui définissent le "done" pour cette feature.

## Risques de régression
Parties du code existant qui pourraient être affectées indirectement.
```

### Étape 3 — Sauvegarder et demander l'approbation
Sauvegarde dans `production_artifacts/{FEATURE_ID}/Technical_Specification.md`.

Demande explicitement à l'utilisateur :
> "Voici l'analyse de la codebase et le Change Request. Tu peux ouvrir
> `production_artifacts/Technical_Specification.md` pour modifier ou commenter.
> Tape **"Approved"** pour lancer le développement parallèle."
