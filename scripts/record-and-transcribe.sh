#!/usr/bin/env bash
# record-and-transcribe.sh — Enregistre le micro et transcrit avec whisper.cpp
#
# Usage :
#   ./scripts/record-and-transcribe.sh [durée_secondes] [langue]
#
# Exemples :
#   ./scripts/record-and-transcribe.sh          # 30s, français
#   ./scripts/record-and-transcribe.sh 60 fr    # 60s, français
#   ./scripts/record-and-transcribe.sh 45 en    # 45s, anglais
#   ./scripts/record-and-transcribe.sh 30 de    # 30s, allemand
#
# Pré-requis système :
#   brew install ffmpeg whisper-cpp
#
# Le modèle GGML (small, ~466 Mo) est téléchargé au premier lancement
# dans <skill>/.models/ (gitignoré). Modifiable via la variable
# WHISPER_MODEL ci-dessous (tiny | base | small | medium | large-v3).

set -euo pipefail

DURATION=${1:-30}
LANG=${2:-fr}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WHISPER_MODEL="${WHISPER_MODEL:-small}"
MODEL_DIR="$SKILL_ROOT/.models"
MODEL_FILE="$MODEL_DIR/ggml-${WHISPER_MODEL}.bin"
MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-${WHISPER_MODEL}.bin"

# ── 1. Outils système ─────────────────────────────────────────────────────────
for cmd in ffmpeg whisper-cli; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "[erreur] $cmd requis."
    case "$cmd" in
      ffmpeg)      echo "         brew install ffmpeg" ;;
      whisper-cli) echo "         brew install whisper-cpp" ;;
    esac
    exit 1
  fi
done

# ── 2. Modèle GGML (téléchargé à la demande) ──────────────────────────────────
if [ ! -f "$MODEL_FILE" ]; then
  mkdir -p "$MODEL_DIR"
  echo "[info] Téléchargement du modèle whisper.cpp '$WHISPER_MODEL' (~466 Mo pour 'small')..."
  if ! curl -L --fail --progress-bar -o "$MODEL_FILE.tmp" "$MODEL_URL"; then
    rm -f "$MODEL_FILE.tmp"
    echo "[erreur] Échec du téléchargement depuis $MODEL_URL"
    exit 1
  fi
  mv "$MODEL_FILE.tmp" "$MODEL_FILE"
fi

# ── 3. Enregistrement micro ───────────────────────────────────────────────────
OUTPUT="/tmp/eleve_$(date +%s).wav"
trap 'rm -f "$OUTPUT" "${OUTPUT%.wav}.txt"' EXIT

echo ""
echo "Enregistrement pendant ${DURATION} secondes..."
echo "Parle maintenant ! (Ctrl+C pour arrêter avant la fin)"
echo ""

ffmpeg -f avfoundation -i ":0" \
  -t "$DURATION" \
  -ar 16000 -ac 1 \
  "$OUTPUT" -y \
  2>/dev/null

if [ ! -s "$OUTPUT" ]; then
  echo "[erreur] Enregistrement échoué."
  echo "         Vérifie ton autorisation micro : Réglages > Confidentialité > Micro."
  exit 1
fi

echo "Enregistrement terminé. Transcription en cours..."
echo ""

# ── 4. Transcription via whisper.cpp ──────────────────────────────────────────
TRANSCRIPT_BASE="${OUTPUT%.wav}"
whisper-cli \
  -m "$MODEL_FILE" \
  -l "$LANG" \
  -f "$OUTPUT" \
  -otxt -of "$TRANSCRIPT_BASE" \
  --no-prints --no-timestamps \
  2>/dev/null

TRANSCRIPT="${TRANSCRIPT_BASE}.txt"
if [ ! -f "$TRANSCRIPT" ]; then
  echo "[erreur] Transcription échouée."
  echo "         Essaie un modèle plus léger : WHISPER_MODEL=base $0 $DURATION $LANG"
  exit 1
fi

echo "=== Transcription ==="
cat "$TRANSCRIPT"
echo "====================="
echo ""
echo "[Copie ce texte et colle-le dans ta conversation avec le professeur.]"
