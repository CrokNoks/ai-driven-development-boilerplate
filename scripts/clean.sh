#!/bin/bash

# Nettoie les worktrees d'une feature ou de toutes les features.
# Usage :
#   bash scripts/clean.sh              → nettoie toutes les features terminées ou en erreur
#   bash scripts/clean.sh <feature_id> → nettoie une feature spécifique

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
  echo "→ Nettoyage de la feature : $FEATURE_ID"

  local ROLES=("engineer" "qa" "devops")
  local BRANCHES=(
    "feature/${FEATURE_ID}-impl"
    "feature/${FEATURE_ID}-tests"
    "feature/${FEATURE_ID}-infra"
  )

  # Supprimer les worktrees enregistrés dans le bare repo
  for ROLE in "${ROLES[@]}"; do
    local WT_PATH="${FEATURE_ID}/${ROLE}"
    if git -C "$APP_REPO" worktree list | grep -q "$WT_PATH" 2>/dev/null; then
      echo "  → Suppression du worktree $WT_PATH..."
      git -C "$APP_REPO" worktree remove --force "$WT_PATH" 2>/dev/null || true
    fi
  done

  # Purger les worktrees orphelins (répertoires supprimés sans `worktree remove`)
  git -C "$APP_REPO" worktree prune 2>/dev/null || true

  # Supprimer les répertoires restants
  if [ -d "$APP_REPO/$FEATURE_ID" ]; then
    rm -rf "${APP_REPO:?}/$FEATURE_ID"
    echo "  ✓ Répertoire app_build/$FEATURE_ID supprimé"
  fi

  # Supprimer les branches
  for BRANCH in "${BRANCHES[@]}"; do
    if git -C "$APP_REPO" branch | grep -q "$BRANCH" 2>/dev/null; then
      git -C "$APP_REPO" branch -D "$BRANCH" 2>/dev/null || true
      echo "  ✓ Branche $BRANCH supprimée"
    fi
  done

  # Mettre à jour le manifest
  # Supprime l'entrée de la feature (nécessite python3 ou jq)
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
    echo "  ⚠  python3 non disponible — mets à jour .agents/state/active.json manuellement"
  fi

  echo ""
}

# ── Mode : feature spécifique ou toutes ───────────────────────────────────────
if [ -n "$1" ]; then
  clean_feature "$1"
else
  # Lister toutes les features dans le manifest
  if command -v python3 &>/dev/null; then
    FEATURES=$(python3 -c "
import json, sys
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
