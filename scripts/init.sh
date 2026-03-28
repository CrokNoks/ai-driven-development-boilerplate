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
    bash "$SCRIPT_DIR/clean.sh" 2>/dev/null || true
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
echo "  (laisser vide pour initialiser un nouveau projet)"
echo ""
read -rp "  > " REPO_URL
echo ""

# ── 4. Initialiser app_build ──────────────────────────────────────────────────
if [ -n "$REPO_URL" ]; then
  echo "→ Clonage en mode bare depuis $REPO_URL..."
  git clone --bare "$REPO_URL" app_build
  echo "  ✓ Dépôt cloné dans app_build/"
else
  echo "→ Initialisation d'un nouveau dépôt bare..."
  git init --bare app_build
  echo "  ✓ Nouveau dépôt initialisé dans app_build/"
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
