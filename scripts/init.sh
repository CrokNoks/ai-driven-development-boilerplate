#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Autonomous AI Developer Pipeline — Init    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

cd "$ROOT_DIR"

# ── 1. Initialiser le dépôt orchestrateur ─────────────────────────────────────
if [ ! -d ".git" ]; then
  echo "→ Initialisation du dépôt orchestrateur..."
  git init
  git add .
  git commit -m "chore: initial setup"
  echo "  ✓ Dépôt orchestrateur initialisé"
else
  echo "  ✓ Dépôt orchestrateur déjà initialisé"
fi

echo ""

# ── 2. Vérifier que app_build n'existe pas déjà ───────────────────────────────
if [ -d "app_build" ]; then
  echo "  ⚠  app_build/ existe déjà."
  echo ""
  read -rp "  Réinitialiser app_build/ ? Tout son contenu sera perdu. [o/N] " CONFIRM
  echo ""
  if [[ "$CONFIRM" =~ ^[oO]$ ]]; then
    echo "→ Nettoyage des worktrees via clean.sh..."
    bash "$SCRIPT_DIR/clean.sh" --all-no-confirm 2>/dev/null || true
    echo "→ Suppression de app_build/..."
    rm -rf app_build
    echo "  ✓ app_build/ supprimé"
    echo ""
  else
    echo "  Annulé."
    exit 0
  fi
fi

# ── 3. Demander l'URL du dépôt ────────────────────────────────────────────────
echo "  URL du dépôt applicatif à cloner :"
echo "  (laisser vide pour initialiser un nouveau projet greenfield)"
echo ""
read -rp "  > " REPO_URL
echo ""

# ── 4. Initialiser app_build ──────────────────────────────────────────────────
if [ -n "$REPO_URL" ]; then
  # — Mode existing : clone bare ───────────────────────────────────────────────
  echo "→ Clonage en mode bare depuis $REPO_URL..."
  git clone --bare "$REPO_URL" app_build
  echo "  ✓ Dépôt cloné dans app_build/"

  # Détecter la branche principale (main ou master)
  DEFAULT_BRANCH=$(git -C app_build symbolic-ref HEAD 2>/dev/null | sed 's|refs/heads/||' || echo "main")
  echo "  ✓ Branche principale détectée : $DEFAULT_BRANCH"

  # Créer le worktree principal
  echo "→ Création du worktree app_build/main..."
  git -C app_build worktree add main "$DEFAULT_BRANCH"
  echo "  ✓ Worktree app_build/main créé sur $DEFAULT_BRANCH"

else
  # — Mode greenfield : bare vide + commit initial ──────────────────────────────
  echo "→ Initialisation d'un nouveau dépôt bare..."
  git init --bare app_build
  echo "  ✓ Bare repo initialisé dans app_build/"

  # Un bare repo vide n'a pas de branche — créer un commit initial via un repo temporaire
  echo "→ Création du commit initial..."
  TMPDIR_INIT=$(mktemp -d)
  git init "$TMPDIR_INIT"
  git -C "$TMPDIR_INIT" commit --allow-empty -m "chore: initial commit"
  git -C "$TMPDIR_INIT" remote add origin "$ROOT_DIR/app_build"
  git -C "$TMPDIR_INIT" push origin HEAD:main
  rm -rf "$TMPDIR_INIT"
  echo "  ✓ Commit initial créé sur main"

  # Créer le worktree principal
  echo "→ Création du worktree app_build/main..."
  git -C app_build worktree add main main
  echo "  ✓ Worktree app_build/main créé"
fi

echo ""

# ── 5. Réinitialiser le manifest ──────────────────────────────────────────────
echo "→ Réinitialisation du manifest de coordination..."
cat > "$ROOT_DIR/.agents/state/active.json" <<'EOF'
{
  "features": {}
}
EOF
echo "  ✓ .agents/state/active.json réinitialisé"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║               Setup terminé ✓                ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  Lance ton premier cycle avec :"
echo ""
echo "    /startcycle \"ton idée\""
echo ""
