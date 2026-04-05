# Skill: Recommend Stack

## Objectif

Mener un Q&A technique avec l'utilisateur pour comprendre les contraintes réelles du projet,
puis produire une recommandation de stack concrète et justifiée.

## Chemins

```
STACK_FILE = app_build/docs/{FEATURE_ID}/stack_recommendation.md
```

> `FEATURE_ID` est lu dans `.agents/state/active.json` (champ `feature_id`).

## Instructions

### Phase 1 — Q&A technique itératif

Mène le Q&A en couvrant les 5 axes dans l'ordre, **1 à 2 questions à la fois**.
Attends les réponses avant de poser les suivantes. Adapte selon ce qui a déjà été précisé.

**Axe 1 — Plateforme cible**
- Web (navigateur) / Mobile natif / Desktop / CLI / API seule / Plusieurs ?
- Si web : SPA, SSR, SSG, ou mixte ? Besoin d'un mode offline ?
- Si mobile : natif ou cross-platform (React Native, Flutter…) ? iOS, Android, ou les deux ?
- Si desktop : quels OS cibles ? Contrainte sur Electron vs natif ?

**Axe 2 — Environnement d'exécution**
- Quelle machine fait tourner l'app ? (serveur cloud, VPS, machine utilisateur, edge, serverless)
- Cloud hébergé (Vercel, Railway, Fly.io, AWS, GCP…) ou auto-hébergé ?
- Containerisation (Docker) souhaitée ou requise ?
- Contraintes d'infrastructure existante à respecter ?

**Axe 3 — Scale et performance**
- Combien d'utilisateurs au lancement ? Croissance prévue ?
- Besoin de temps réel (WebSocket, streaming, polling) ou traitement asynchrone ?
- Haute disponibilité / tolérance aux pannes requise ?

**Axe 4 — Données**
- Base de données requise ? SQL, NoSQL, fichiers locaux, pas de persistance ?
- Volume de données estimé ?
- Contraintes de conformité (RGPD, HIPAA, données sensibles) ?

**Axe 5 — Contraintes d'équipe**
- Langage ou framework imposé ou fortement préféré ?
- Qui maintient et déploie ? Niveau DevOps disponible ?
- Budget infrastructure (gratuit, low-cost, pas de contrainte) ?

---

### Phase 2 — Recommandation

Une fois les 5 axes couverts, formule une recommandation concrète et justifiée.

Crée `app_build/docs/{FEATURE_ID}/stack_recommendation.md` :

```markdown
# Stack Recommendation — {NOM DU PROJET}

## Plateforme
{web SSR / mobile cross-platform / CLI / etc.}

## Stack recommandée

| Composant | Choix | Version recommandée |
|---|---|---|
| Runtime / Langage | {ex: Node.js} | {ex: 22 LTS} |
| Framework principal | {ex: Next.js} | {ex: 15} |
| Base de données | {ex: PostgreSQL} | {ex: 16} |
| Hébergement | {ex: Vercel + Railway} | — |
| Autres | {ex: Redis, S3, Docker} | — |

## Justification
{2-3 phrases expliquant pourquoi ce choix pour CE projet, en lien direct avec les
contraintes exprimées par l'utilisateur.}

## Alternatives écartées

| Alternative | Raison du rejet |
|---|---|
| {ex: Django} | {ex: overkill pour ce volume, équipe JS} |
| {ex: MySQL} | {ex: moins adapté aux données relationnelles complexes} |

## Contraintes identifiées
{Liste des contraintes relevées pendant le Q&A qui ont guidé les choix.}
```

---

### Phase 3 — Présentation dans le chat

Résume la recommandation directement dans la conversation :

```
**Recommandation de stack — {NOM DU PROJET}**

**Plateforme** : {web SSR / mobile / CLI / etc.}

**Stack recommandée** :
- Runtime / Langage : {ex: Node.js 22}
- Framework : {ex: Next.js 15}
- Base de données : {ex: PostgreSQL 16}
- Hébergement : {ex: Vercel (front) + Railway (DB)}
- Autres : {ex: Docker pour le dev local}

**Justification** : {2-3 phrases}

**Alternatives écartées** : {ex: Django — overkill pour ce volume}

Des ajustements ? Ou valide pour que le PM rédige la spec.
```

---

### Phase 4 — Validation et handoff

Attends la validation explicite de l'utilisateur ("ok", "validé", "go", ou équivalent).

Si l'utilisateur demande des ajustements : modifie `stack_recommendation.md`, commite,
et reprends la Phase 3.

Une fois validé :

```bash
cd app_build/
git checkout main
git add docs/{FEATURE_ID}/stack_recommendation.md
git commit -m "docs({FEATURE_ID}): recommandation de stack"
```

Annonce : **"Stack validée. Le PM va maintenant rédiger la spec complète."**
