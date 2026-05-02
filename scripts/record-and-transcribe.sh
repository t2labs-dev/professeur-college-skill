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
# Dépendances (installées automatiquement si Homebrew est disponible) :
#   - ffmpeg   : brew install ffmpeg
#   - whisper  : pip install openai-whisper

set -euo pipefail

DURATION=${1:-30}
LANG=${2:-fr}
OUTPUT="/tmp/eleve_$(date +%s).wav"

# ── 1. Vérifier / installer ffmpeg ────────────────────────────────────────────
if ! command -v ffmpeg &>/dev/null; then
  echo "[info] ffmpeg non trouvé."
  if command -v brew &>/dev/null; then
    echo "[info] Installation via Homebrew..."
    brew install ffmpeg
  else
    echo "[erreur] ffmpeg est requis. Installe-le : brew install ffmpeg"
    echo "         (si Homebrew n'est pas installé : https://brew.sh)"
    exit 1
  fi
fi

# ── 2. Vérifier / installer whisper ───────────────────────────────────────────
if ! command -v whisper &>/dev/null; then
  echo "[info] Whisper non trouvé."
  if command -v pip3 &>/dev/null; then
    echo "[info] Installation via pip..."
    pip3 install --quiet openai-whisper
  elif command -v pip &>/dev/null; then
    pip install --quiet openai-whisper
  else
    echo "[erreur] pip est requis pour installer Whisper."
    echo "         Installe Python 3 : brew install python3"
    exit 1
  fi
fi

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

whisper "$OUTPUT" \
  --language "$LANG" \
  --model small \
  --output_format txt \
  --output_dir "$OUTDIR" \
  2>/dev/null

TRANSCRIPT="${OUTDIR}/${BASENAME}.txt"

if [ ! -f "$TRANSCRIPT" ]; then
  echo "[erreur] Transcription échouée. Essaie avec le modèle base :"
  echo "         whisper $OUTPUT --language $LANG --model base"
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
