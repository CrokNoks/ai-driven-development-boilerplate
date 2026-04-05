#!/bin/bash

# Nettoie la branche feature et l'entrée active.json d'une feature ou de toutes.
# Le worktree app_build/main est permanent — il n'est jamais supprimé.
#
# Usage :
#   bash scripts/clean.sh <feature_id>     → nettoie une feature spécifique
#   bash scripts/clean.sh                  → nettoie toutes les features (avec confirmation)
#   bash scripts/clean.sh --all-no-confirm → nettoie tout sans demander (usage interne)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_REPO="$ROOT_DIR/app_build"
MANIFEST="$ROOT_DIR/.agents/state/active.json"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Autonomous AI Developer Pipeline — Clean   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── Vérifications préliminaires ───────────────────────────────────────────────
if [ ! -d "$APP_REPO" ]; then
  echo "  ✓ app_build/ n'existe pas, rien à nettoyer."
  exit 0
fi

if [ ! -f "$MANIFEST" ]; then
  echo "  ⚠  Manifest introuvable : $MANIFEST"
  exit 1
fi

# ── Fonction de nettoyage d'une feature ───────────────────────────────────────
clean_feature() {
  local FEATURE_ID="$1"
  local BRANCH="feature/${FEATURE_ID}"
  echo "→ Nettoyage de la feature : $FEATURE_ID"

  # S'assurer que main n'est pas sur la branche feature avant de la supprimer
  if [ -d "$APP_REPO/main" ]; then
    CURRENT_BRANCH=$(git -C "$APP_REPO/main" branch --show-current 2>/dev/null || echo "")
    if [ "$CURRENT_BRANCH" = "$BRANCH" ]; then
      echo "  → Retour sur main dans le worktree..."
      git -C "$APP_REPO/main" checkout main 2>/dev/null || true
    fi
  fi

  # Supprimer la branche feature dans le bare repo
  if git -C "$APP_REPO" branch | grep -q "feature/${FEATURE_ID}$" 2>/dev/null; then
    git -C "$APP_REPO" branch -D "$BRANCH" 2>/dev/null || true
    echo "  ✓ Branche $BRANCH supprimée"
  else
    echo "  ✓ Branche $BRANCH absente (déjà supprimée ou jamais créée)"
  fi

  # Purger les worktrees orphelins éventuels
  git -C "$APP_REPO" worktree prune 2>/dev/null || true

  # Mettre à jour le manifest
  if command -v python3 &>/dev/null; then
    python3 - "$MANIFEST" "$FEATURE_ID" <<'EOF'
import json, sys
path, fid = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = json.load(f)
data.get("features", {}).pop(fid, None)
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
EOF
    echo "  ✓ Manifest mis à jour"
  else
    echo "  ⚠  python3 non disponible — retire manuellement $FEATURE_ID de .agents/state/active.json"
  fi

  echo ""
}

# ── Mode : feature spécifique, toutes, ou toutes sans confirmation ─────────────
if [ "$1" = "--all-no-confirm" ]; then
  # Usage interne (appelé par init.sh lors d'une réinitialisation)
  if command -v python3 &>/dev/null; then
    FEATURES=$(python3 -c "
import json
with open('$MANIFEST') as f:
    data = json.load(f)
for fid in data.get('features', {}).keys():
    print(fid)
" 2>/dev/null || echo "")
    while IFS= read -r FEATURE_ID; do
      [ -n "$FEATURE_ID" ] && clean_feature "$FEATURE_ID"
    done <<< "$FEATURES"
  fi

elif [ -n "$1" ]; then
  clean_feature "$1"

else
  # Lister toutes les features dans le manifest
  if command -v python3 &>/dev/null; then
    FEATURES=$(python3 -c "
import json
with open('$MANIFEST') as f:
    data = json.load(f)
for fid in data.get('features', {}).keys():
    print(fid)
")
  else
    echo "  ⚠  python3 requis pour lire le manifest."
    exit 1
  fi

  if [ -z "$FEATURES" ]; then
    echo "  ✓ Aucune feature active dans le manifest."
  else
    echo "  Features à nettoyer :"
    echo "$FEATURES" | sed 's/^/    - /'
    echo ""
    read -rp "  Confirmer le nettoyage de toutes ces features ? [o/N] " CONFIRM
    echo ""
    if [[ "$CONFIRM" =~ ^[oO]$ ]]; then
      while IFS= read -r FEATURE_ID; do
        clean_feature "$FEATURE_ID"
      done <<< "$FEATURES"
    else
      echo "  Annulé."
      exit 0
    fi
  fi
fi

echo "╔══════════════════════════════════════════════╗"
echo "║             Nettoyage terminé ✓              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
