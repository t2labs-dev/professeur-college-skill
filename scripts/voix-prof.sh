#!/usr/bin/env bash
# voix-prof.sh — Orchestrateur vocal du skill professeur-college
#
# Sélectionne automatiquement le meilleur backend disponible :
#   1. OpenAI TTS si une clé API est configurée (qualité quasi-humaine)
#   2. macOS `say` sinon, si on est sur Mac (gratuit, hors-ligne)
#   3. Texte simple sinon (fallback Linux/Windows sans clé)
#
# Usage:
#   ./scripts/voix-prof.sh <matière> "<texte>" [style]
#
# Matières  : francais, maths, histoire, svt, physique, anglais, allemand, techno
# Style     : normal | important | rapide | langue
#
# Configuration de la clé OpenAI (priorité décroissante) :
#   1. Variable d'env OPENAI_API_KEY
#   2. Fichier ~/.config/professeur-college/openai-key
#   3. Fichier <skill>/.openai-key (gitignored)

set -euo pipefail

MATIERE="${1:-francais}"
TEXTE="${2:-}"
STYLE="${3:-normal}"

if [ -z "$TEXTE" ]; then
  echo "Usage: $0 <matière> \"<texte>\" [normal|important|rapide|langue]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Détection de la clé OpenAI ────────────────────────────────────────────────
has_openai_key() {
  [ -n "${OPENAI_API_KEY:-}" ] && return 0
  for path in \
    "$HOME/.config/professeur-college/openai-key" \
    "$SCRIPT_DIR/../.openai-key"; do
    [ -f "$path" ] && [ -s "$path" ] && return 0
  done
  return 1
}

# ── Sélection du backend ──────────────────────────────────────────────────────
if has_openai_key; then
  exec "$SCRIPT_DIR/openai-tts-prof.sh" "$MATIERE" "$TEXTE" "$STYLE"
elif [[ "$OSTYPE" == "darwin"* ]] && command -v say &>/dev/null; then
  exec "$SCRIPT_DIR/say-prof.sh" "$MATIERE" "$TEXTE" "$STYLE"
else
  # Fallback texte : on imprime simplement, en signalant la matière et le style
  echo ""
  echo "[Voix indisponible — texte uniquement]"
  echo "[Prof : $MATIERE | Style : $STYLE]"
  echo ""
  # Strip prosody markers from text
  echo "$TEXTE" | sed -E 's/\[\[[^]]*\]\]//g'
  echo ""
fi
