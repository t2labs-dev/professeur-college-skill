#!/usr/bin/env bash
# prononciation-prof.sh — Diagnostic de prononciation phonème par phonème
#
# Compare la prononciation effective de l'élève (wav2vec2-phoneme local)
# aux phonèmes attendus (espeak-ng) et liste les substitutions / omissions /
# phonèmes inattendus. Le LLM en mode prof interprète le diff.
#
# Usage :
#   ./scripts/prononciation-prof.sh "<texte cible>" [en|de|fr] [durée_s]
#
# Exemples :
#   ./scripts/prononciation-prof.sh "think" en
#   ./scripts/prononciation-prof.sh "I would have known" en 6
#   ./scripts/prononciation-prof.sh "ich möchte" de 4
#
# Pré-requis :
#   - système : brew install ffmpeg espeak-ng
#   - Python  : transformers, torch, soundfile, phonemizer (auto-installés
#               dans <skill>/.venv au premier lancement, ~1.5 Go)
#
# Le modèle wav2vec2-lv-60-espeak-cv-ft (~1 Go) est téléchargé au premier
# appel et caché dans ~/.cache/huggingface/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_venv.sh
source "$SCRIPT_DIR/_venv.sh"

TEXTE="${1:-}"
LANG="${2:-en}"
DUREE="${3:-5}"

if [ -z "$TEXTE" ]; then
  sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
fi

# ── 1. Outils système ─────────────────────────────────────────────────────────
for cmd in ffmpeg espeak-ng; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "[erreur] $cmd requis. brew install $cmd"
    exit 1
  fi
done

PYHELPER="$SCRIPT_DIR/prononciation_check.py"
[ -f "$PYHELPER" ] || { echo "[erreur] $PYHELPER manquant."; exit 1; }

# ── 2. Paquets Python dans le venv local ──────────────────────────────────────
ensure_packages "import transformers, torch, soundfile, phonemizer" \
  transformers torch soundfile phonemizer

# ── 3. Enregistrement micro ───────────────────────────────────────────────────
WAV="/tmp/prononciation_$$.wav"
trap 'rm -f "$WAV"' EXIT

echo ""
echo "Cible : « $TEXTE »  ($LANG)"
echo "Enregistrement pendant ${DUREE}s. Prononce maintenant !"
echo ""

ffmpeg -f avfoundation -i ":0" \
  -t "$DUREE" \
  -ar 16000 -ac 1 \
  "$WAV" -y \
  2>/dev/null

if [ ! -s "$WAV" ]; then
  echo "[erreur] Enregistrement échoué."
  echo "         Vérifie l'autorisation micro : Réglages > Confidentialité > Micro."
  exit 1
fi

# ── 4. Analyse phonétique ─────────────────────────────────────────────────────
echo "Analyse en cours (premier appel : téléchargement du modèle ~1 Go)..."
echo ""

"$VENV_PY" "$PYHELPER" "$WAV" "$TEXTE" "$LANG"
