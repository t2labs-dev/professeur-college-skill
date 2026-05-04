#!/usr/bin/env bash
# record-and-transcribe.sh — Enregistre le micro et transcrit avec Whisper
#
# Usage:
#   ./scripts/record-and-transcribe.sh [durée_secondes] [langue]
#
# Exemples:
#   ./scripts/record-and-transcribe.sh          # 30s, français
#   ./scripts/record-and-transcribe.sh 60 fr    # 60s, français
#   ./scripts/record-and-transcribe.sh 45 en    # 45s, anglais
#   ./scripts/record-and-transcribe.sh 30 de    # 30s, allemand
#
# Dépendances (auto-installées dans <skill>/.venv au premier lancement) :
#   - ffmpeg   : brew install ffmpeg   (système)
#   - whisper  : openai-whisper        (Python, installé dans le venv)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_venv.sh
source "$SCRIPT_DIR/_venv.sh"

DURATION=${1:-30}
LANG=${2:-fr}
OUTPUT="/tmp/eleve_$(date +%s).wav"

# ── 1. ffmpeg (système) ───────────────────────────────────────────────────────
if ! command -v ffmpeg &>/dev/null; then
  echo "[erreur] ffmpeg requis. brew install ffmpeg"
  exit 1
fi

# ── 2. Whisper (venv local) ───────────────────────────────────────────────────
ensure_packages "import whisper" openai-whisper
WHISPER_BIN="$VENV_DIR/bin/whisper"

# ── 3. Enregistrement ──────────────────────────────────────────────────────────
echo ""
echo "Enregistrement pendant ${DURATION} secondes..."
echo "Parle maintenant ! (Ctrl+C pour arrêter avant la fin)"
echo ""

# -f avfoundation = source micro macOS ; ":0" = micro par défaut
ffmpeg -f avfoundation -i ":0" \
  -t "$DURATION" \
  -ar 16000 -ac 1 \
  "$OUTPUT" -y \
  2>/dev/null

if [ ! -f "$OUTPUT" ] || [ ! -s "$OUTPUT" ]; then
  echo "[erreur] Enregistrement échoué."
  echo "         Vérifie que ton micro est autorisé dans Réglages système > Confidentialité > Micro."
  exit 1
fi

echo "Enregistrement terminé. Transcription en cours..."
echo ""

# ── 4. Transcription ──────────────────────────────────────────────────────────
OUTDIR=$(dirname "$OUTPUT")
BASENAME=$(basename "$OUTPUT" .wav)

"$WHISPER_BIN" "$OUTPUT" \
  --language "$LANG" \
  --model small \
  --output_format txt \
  --output_dir "$OUTDIR" \
  2>/dev/null

TRANSCRIPT="${OUTDIR}/${BASENAME}.txt"

if [ ! -f "$TRANSCRIPT" ]; then
  echo "[erreur] Transcription échouée. Essaie avec le modèle base :"
  echo "         $WHISPER_BIN $OUTPUT --language $LANG --model base"
  exit 1
fi

# ── 5. Affichage du résultat ──────────────────────────────────────────────────
echo "=== Transcription ==="
cat "$TRANSCRIPT"
echo "====================="
echo ""
echo "[Copie ce texte et colle-le dans ta conversation avec le professeur.]"

# Nettoyage
rm -f "$OUTPUT"
