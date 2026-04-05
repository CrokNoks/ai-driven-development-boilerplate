---
description: Affiche l'état du pipeline en cours
---

Lis `.agents/state/active.json` et affiche un résumé structuré de l'état du pipeline.

## Comportement

Affiche dans le chat :

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Pipeline Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Mode          : greenfield | existing
 Feature active: {feature_id}
 Codebase      : {codebase_dir}

 Features
 ────────
 {FEATURE_ID_1}  [{phase}]
   engineer   {status}
   tester     {status}
   reviewer   {status}
   doc_writer {status}
   pr_url     {url si présente}

 {FEATURE_ID_2}  [{phase}]
   …
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Si `active.json` est vide ou absent, affiche :
```
Aucun pipeline actif. Lance /startcycle "ton idée" pour commencer.
```

Si une feature est en `review_failed`, liste les problèmes bloquants sous la feature concernée.
