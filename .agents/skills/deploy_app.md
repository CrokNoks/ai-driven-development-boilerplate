# Skill: Deploy App (générique)

## Objectif
Packager et déployer l'application selon le stack détecté.
Ce skill est le **fallback générique** de l'orchestrateur.

> Si le dépôt applicatif définit `.agents/skills/deploy_app.md` dans son worktree,
> ce fichier-là sera utilisé à la place — il prend la priorité sur celui-ci.

## Instructions

1. **Détecter le stack** : inspecte `Technical_Specification.md` et les fichiers
   à la racine du worktree pour identifier le stack (Node, Python, Go, etc.).

2. **Installer les dépendances** :
   ```bash
   npm install                        # Node
   pip install -r requirements.txt    # Python
   go mod download                    # Go
   ```

3. **Lancer le serveur** en arrière-plan :
   ```bash
   npm run dev      # Node
   python app.py    # Python
   go run .         # Go
   ```

4. **Rapport** : affiche le lien localhost à l'utilisateur.
