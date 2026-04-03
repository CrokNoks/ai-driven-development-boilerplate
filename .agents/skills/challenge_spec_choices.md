# Skill: Challenge Spec Choices

## Objectif
Analyser les choix techniques et l'architecture proposés dans la spécification pour en vérifier la robustesse, la maintenabilité et la pertinence.

## Instructions

### 1. Challenge technique
Analyse la section "Stack technique" et "Architecture" de la spec :
- **Choix du stack** : Est-ce adapté au problème ? N'y a-t-il pas plus simple ou plus robuste ?
- **Architecture** : Les responsabilités sont-elles bien séparées ? Le flux de données est-il clair ?
- **Dette technique** : Le plan introduit-il des raccourcis dangereux pour la suite ?
- **Performance/Sécurité** : Y a-t-il des risques évidents ?

### 2. Questions critiques
Rédige 2 ou 3 questions percutantes pour forcer le PM (et l'utilisateur) à justifier leurs choix :
"Pourquoi avoir choisi X plutôt que Y alors que..."
"Attention au risque de..."

### 3. Publication
Poste ton feedback directement dans le chat après celui du `@spec_checker`.
Format :
---
**🛡️ Technical Challenge (@spec_challenger)**
- [Question/Alerte 1]
- [Question/Alerte 2]
...
---
