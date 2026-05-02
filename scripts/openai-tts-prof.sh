#!/usr/bin/env bash
# openai-tts-prof.sh — Lit un texte avec l'API OpenAI TTS, voix par matière
#
# Usage:
#   ./scripts/openai-tts-prof.sh <matière> "<texte>" [style]
#
# Matières  : francais, maths, histoire, svt, physique, anglais, allemand, techno
# Style     : normal | important | rapide | langue
#
# Pré-requis :
#   - Clé API OpenAI dans la variable d'env OPENAI_API_KEY
#     ou dans le fichier ~/.config/professeur-college/openai-key
#     ou dans <skill>/.openai-key (gitignored)
#   - curl (universel)
#   - afplay (macOS) OU mpg123/ffplay/mpv (Linux) pour la lecture audio

set -euo pipefail

MATIERE="${1:-francais}"
TEXTE="${2:-}"
STYLE="${3:-normal}"

if [ -z "$TEXTE" ]; then
  echo "Usage: $0 <matière> \"<texte>\" [normal|important|rapide|langue]" >&2
  exit 1
fi

# ── Récupération de la clé API ────────────────────────────────────────────────
get_api_key() {
  if [ -n "${OPENAI_API_KEY:-}" ]; then
    echo "$OPENAI_API_KEY"
    return 0
  fi
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  for path in \
    "$HOME/.config/professeur-college/openai-key" \
    "$script_dir/../.openai-key"; do
    if [ -f "$path" ] && [ -s "$path" ]; then
      head -1 "$path" | tr -d '[:space:]'
      return 0
    fi
  done
  return 1
}

API_KEY=$(get_api_key) || {
  echo "[erreur] Clé OpenAI introuvable." >&2
  echo "         Définis OPENAI_API_KEY ou crée ~/.config/professeur-college/openai-key" >&2
  exit 2
}

# ── Mapping matière → voix OpenAI + débit de base ─────────────────────────────
case "$MATIERE" in
  francais|français)            VOIX="nova"    ; BASE_SPEED=1.00 ;;
  maths|mathematiques|mathématiques) VOIX="onyx"    ; BASE_SPEED=0.95 ;;
  histoire|histoire-geographie|histoire-geo|hg) VOIX="shimmer" ; BASE_SPEED=1.00 ;;
  svt)                          VOIX="coral"   ; BASE_SPEED=1.00 ;;
  physique|physique-chimie)     VOIX="echo"    ; BASE_SPEED=0.95 ;;
  anglais|english|lv1)          VOIX="fable"   ; BASE_SPEED=0.95 ;;
  allemand|deutsch|lv2)         VOIX="sage"    ; BASE_SPEED=0.90 ;;
  techno|technologie)           VOIX="alloy"   ; BASE_SPEED=1.00 ;;
  *)                            VOIX="nova"    ; BASE_SPEED=1.00 ;;
esac

# ── Application du style sur le débit ─────────────────────────────────────────
multiply() { awk -v a="$1" -v b="$2" 'BEGIN { printf "%.2f", a * b }'; }

case "$STYLE" in
  normal)    SPEED=$BASE_SPEED ;;
  important) SPEED=$(multiply "$BASE_SPEED" 0.85) ;;
  rapide)    SPEED=$(multiply "$BASE_SPEED" 1.15) ;;
  langue)    SPEED=$(multiply "$BASE_SPEED" 0.75) ;;
  *)         SPEED=$BASE_SPEED ;;
esac

# ── Nettoyage des marqueurs de prosodie macOS (non supportés par OpenAI) ──────
# [[slnc N]] → ", " (pause naturelle via virgule)
# [[emph +]] → "" (l'emphase est gérée par le modèle)
# [[rate N]] → ""
TEXTE_CLEAN=$(echo "$TEXTE" | sed -E 's/\[\[slnc [0-9]+\]\]/, /g; s/\[\[emph \+\]\]//g; s/\[\[rate [0-9]+\]\]//g; s/\[\[[^]]*\]\]//g')

# ── Appel à l'API OpenAI ──────────────────────────────────────────────────────
TMPFILE="/tmp/voix-prof-$$.mp3"
trap 'rm -f "$TMPFILE"' EXIT

# Échappement JSON minimal
TEXTE_JSON=$(printf '%s' "$TEXTE_CLEAN" | python3 -c 'import sys, json; print(json.dumps(sys.stdin.read()))')

HTTP_CODE=$(curl -s -o "$TMPFILE" -w "%{http_code}" \
  https://api.openai.com/v1/audio/speech \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"tts-1-hd\",\"voice\":\"$VOIX\",\"input\":$TEXTE_JSON,\"speed\":$SPEED}")

if [ "$HTTP_CODE" != "200" ]; then
  echo "[erreur] OpenAI a renvoyé HTTP $HTTP_CODE" >&2
  cat "$TMPFILE" >&2
  exit 3
fi

# ── Lecture audio ─────────────────────────────────────────────────────────────
if command -v afplay &>/dev/null; then
  afplay "$TMPFILE"
elif command -v mpg123 &>/dev/null; then
  mpg123 -q "$TMPFILE"
elif command -v ffplay &>/dev/null; then
  ffplay -nodisp -autoexit -loglevel quiet "$TMPFILE"
elif command -v mpv &>/dev/null; then
  mpv --no-terminal "$TMPFILE"
else
  KEEP="/tmp/voix-prof-keep-$(date +%s).mp3"
  cp "$TMPFILE" "$KEEP"
  echo "[info] Pas de lecteur audio détecté. Fichier MP3 sauvegardé : $KEEP" >&2
  echo "       Installe mpg123, ffplay ou mpv pour la lecture automatique." >&2
fi