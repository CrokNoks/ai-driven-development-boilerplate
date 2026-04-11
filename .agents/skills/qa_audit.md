# Skill: qa_audit

## Objectif

Effectuer un audit UX/E2E complet de l'application en simulant plusieurs personae sur les parcours critiques. Produire un rapport `QA_REPORT.md` structuré et actionnable.

---

## Étape 0 — Recueillir le contexte

Avant de commencer, identifie les informations suivantes. Si elles ne sont pas fournies dans le prompt d'invocation, lis les fichiers du projet pour les déduire :

- **URL / point d'entrée** de l'application
- **Stack technique** (framework front, API, base de données)
- **Parcours critiques à couvrir** (liste des scénarios utilisateur)

Si les parcours critiques ne sont pas fournis, déduis-les depuis la spec ou le code source (routes, navigation, formulaires principaux).

---

## Étape 1 — Exploration préliminaire

Avant de simuler les personas, lis et inspecte :

1. La structure du projet (répertoires, fichiers principaux)
2. Les routes et pages disponibles
3. Les composants de formulaire et leurs validateurs
4. Les handlers d'erreur et les états de chargement
5. La configuration d'accessibilité (aria-labels, roles, focus management)

Cela te permet de savoir *où chercher* lors de la simulation.

---

## Étape 2 — Simulation par persona × parcours

Pour chaque combinaison **persona × parcours critique**, procède ainsi :

### Personae à simuler

#### Persona 1 — Marie, 58 ans, peu à l'aise avec le numérique
- Smartphone Android bas de gamme, connexion 4G faible
- Lit tout, ne devine rien, clique uniquement sur ce qui est explicite
- Abandonne au moindre message d'erreur non compréhensible
- **Focus** : accessibilité des labels, taille des zones cliquables, clarté des messages d'erreur, lisibilité des textes

#### Persona 2 — Théo, 24 ans, développeur front, impatient et power user
- Utilise raccourcis clavier, ouvre la console, teste les edge cases
- Soumet des formulaires vides, insère émojis et HTML dans les champs, double-clique sur les boutons de soumission
- **Focus** : validation des inputs, gestion des états de chargement, comportement au spam de clics, résilience aux injections

#### Persona 3 — Sandra, 41 ans, directrice marketing, mobile-first
- Navigue exclusivement sur iPhone, souvent entre deux réunions
- Attend un parcours fluide en moins de 3 taps pour toute action clé
- Très sensible au wording, à la cohérence de marque, aux micro-copies
- **Focus** : responsive mobile, cohérence des CTA, qualité des micro-textes, temps perçu de chargement

#### Persona 4 — Karim, 35 ans, malvoyant, utilise un lecteur d'écran
- Navigue au clavier + VoiceOver/NVDA
- Dépend des aria-labels, du focus visible, de la hiérarchie des headings
- **Focus** : accessibilité WCAG 2.1 AA, navigation clavier complète, contrastes, alternatives textuelles des images

### Méthode pour chaque simulation

Pour chaque parcours × chaque persona :

1. **Parcours pas à pas** : décris chaque action, chaque écran traversé
2. **Frictions détectées** : tout ce qui ralentit, confuse ou bloque
3. **Bugs fonctionnels** : comportements cassés, erreurs, états incohérents — pointer le fichier et la ligne
4. **Problèmes d'accessibilité** : WCAG, navigation clavier, contrastes
5. **Incohérences UX** : wording, hiérarchie visuelle, logique de navigation, feedback manquant
6. **Score de complétion** : `oui` / `oui avec friction` / `abandon`

### Cas à tester systématiquement

- États vides (liste vide, pas de résultats, premier usage)
- États d'erreur (réseau KO, validation échouée, 404, 500)
- Timeouts et réponses lentes
- Doubles soumissions (clic répété sur un bouton)
- Formulaires soumis vides ou avec données invalides
- Champs avec émojis, HTML, chaînes très longues, caractères spéciaux

---

## Étape 3 — Rédiger QA_REPORT.md

Crée le fichier `{APP_BUILD_PATH}/docs/qa/QA_REPORT.md` avec la structure suivante :

```markdown
# QA Audit Report — {FEATURE_ID ou nom de l'application}

**Date** : {date}
**Auditeur** : @qa
**Stack** : {stack}
**Parcours couverts** : {liste}

---

## Partie 1 — Matrice de résultats

| Parcours | Marie | Théo | Sandra | Karim | Total problèmes |
|---|---|---|---|---|---|
| {Parcours 1} | score | score | score | score | N |
| {Parcours 2} | ... | ... | ... | ... | N |

Légende des scores : ✅ Complété / ⚠️ Avec friction / ❌ Abandon

---

## Partie 2 — Liste exhaustive des problèmes

### BUG-001 — {titre court}
- **Sévérité** : bloquant / majeur / mineur
- **Catégorie** : bug / UX / accessibilité / performance / wording
- **Persona(s)** : Marie, Théo...
- **Parcours / étape** : {parcours} → {étape}
- **Description** : {description précise}
- **Fichier** : `{chemin/fichier.tsx}:{ligne}` *(si applicable)*
- **Suggestion** : {correction proposée}

*(répéter pour chaque problème)*

---

## Partie 3 — Top 10 des corrections prioritaires

| Priorité | ID | Problème | Personae affectées | Sévérité | Effort |
|---|---|---|---|---|---|
| 1 | BUG-001 | ... | 3/4 | bloquant | rapide |
| ... | | | | | |

Effort : rapide (< 2h) / moyen (demi-journée) / complexe (> 1 jour)

---

## Partie 4 — Score global et verdict

**Score d'utilisabilité** : {X}/100

**Points forts** :
- ...

**3 chantiers structurels prioritaires** :
1. ...
2. ...
3. ...
```

---

## Étape 4 — Fin du skill

Une fois `QA_REPORT.md` produit :

1. Affiche un résumé : score global, nombre total de problèmes par sévérité, top 3 corrections urgentes.
2. Indique à l'utilisateur que le rapport est disponible dans `docs/qa/QA_REPORT.md` et que le `@pm` peut le traiter pour planifier les corrections.
3. **Ne pas modifier `active.json`** — ce skill est hors pipeline automatique.
