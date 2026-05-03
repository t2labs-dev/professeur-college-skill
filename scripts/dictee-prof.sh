#!/usr/bin/env bash
# dictee-prof.sh — Dictée structurée style brevet
#
# Usage:
#   ./scripts/dictee-prof.sh <matière> "<texte>" [pause_fixe_secondes]
#
# Workflow réel d'une dictée du brevet (calé sur l'audio officiel DNB 2003) :
#   1. Phase 1 : lecture intégrale au tempo normal (contextualisation)
#   2. Phase 2 : pour chaque phrase :
#        a. Pour chaque groupe de souffle (chunk de 5-10 mots, ponctuation
#           parlée à la fin) :
#             - lecture lente
#             - pause d'écriture (~1.2 s/mot, 4-12 s)
#             - relecture (même audio)
#             - courte pause (2 s)
#        b. Récap de la phrase entière en lecture continue (au tempo normal)
#        c. Pause inter-phrase (3 s)
#   3. Phase 3 : relecture finale en chunks continus avec ponctuation parlée
#
# Voix continue :
#   - Backend `say`  : un seul appel par phase, avec [[slnc N]] markers
#   - Backend OpenAI : MP3 par chunk unique + recap par phrase, concat ffmpeg
#
# Pour OpenAI : ffmpeg requis (brew install ffmpeg).

set -euo pipefail

MATIERE="${1:-francais}"
TEXTE="${2:-}"
PAUSE_OVERRIDE="${3:-}"

if [ -z "$TEXTE" ]; then
  echo "Usage: $0 <matière> \"<texte>\" [pause_fixe_secondes]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Détection backend ─────────────────────────────────────────────────────────
detect_backend() {
  if [ -n "${OPENAI_API_KEY:-}" ] || \
     [ -f "$HOME/.config/professeur-college/openai-key" ] || \
     [ -f "$SCRIPT_DIR/../.openai-key" ]; then
    echo "openai"
  elif [[ "$OSTYPE" == "darwin"* ]] && command -v say &>/dev/null; then
    echo "say"
  else
    echo "text"
  fi
}

BACKEND=$(detect_backend)

# ── Découpage en chunks par phrase ───────────────────────────────────────────
# Chaque ponctuation interne (, ; :) est un chunk boundary, pour que la
# ponctuation soit dictée. Les groupes > MAX_W mots sont hard-split.
# Output : un chunk par ligne, sentinelle "[END_SENTENCE]" entre les phrases.
chunk_by_sentence() {
  python3 -c '
import sys, re

text = sys.argv[1]
MAX_W = 10
TARGET = 7

PUNCT_SPOKEN = {
    ",": "virgule",
    ";": "point-virgule",
    ":": "deux points",
    ".": "point",
    "?": "point d’interrogation",
    "!": "point d’exclamation",
    "…": "points de suspension",
}

def announce(c):
    c = c.rstrip()
    if c and c[-1] in PUNCT_SPOKEN:
        return c + " " + PUNCT_SPOKEN[c[-1]]
    return c

def split_long(words):
    return [words[i:i+TARGET] for i in range(0, len(words), TARGET)]

for s in re.split(r"(?<=[.!?])\s+", text.strip()):
    s = s.strip()
    if not s:
        continue
    has_chunks = False
    for part in re.split(r"(?<=[,;:])\s+", s):
        pw = part.split()
        if not pw:
            continue
        if len(pw) <= MAX_W:
            print(announce(part))
            has_chunks = True
        else:
            for sub in split_long(pw):
                print(announce(" ".join(sub)))
                has_chunks = True
    if has_chunks:
        print("[END_SENTENCE]")
' "$1"
}

# ── Pause d'écriture adaptée à la longueur du chunk ──────────────────────────
calc_pause() {
  if [ -n "$PAUSE_OVERRIDE" ]; then
    echo "$PAUSE_OVERRIDE"
    return
  fi
  local words
  words=$(echo "$1" | wc -w | tr -d ' ')
  # ~1.2 s/mot, 4-12 s (calé sur l'audio brevet)
  local p
  p=$(( (words * 12 + 5) / 10 ))
  [ "$p" -lt 4 ] && p=4
  [ "$p" -gt 12 ] && p=12
  echo "$p"
}

INTRO_P1="Voici le texte de la dictée. Première lecture, écoute attentivement."
INTRO_P2="Munissez-vous d’un stylo, voici la dictée."
INTRO_P3="La dictée est terminée. Dernière lecture, sois attentif à la ponctuation et aux accords."
OUTRO="Relis une dernière fois ta copie. Bon courage."

GAP_AFTER_REPEAT=2          # pause après la 2e lecture du chunk
GAP_BETWEEN_SENTENCES=3     # pause après le récap de phrase

case "$BACKEND" in
  # ════════════════════════════════════════════════════════════════════════════
  # BACKEND say : voix continue par phase via [[slnc N]] markers
  # ════════════════════════════════════════════════════════════════════════════
  say)
    # ── Construction du texte Phase 2 ────────────────────────────────────────
    PHASE2_TEXT="$INTRO_P2 [[slnc 1500]]"

    sentence_chunks=()
    while IFS= read -r line; do
      if [ "$line" = "[END_SENTENCE]" ]; then
        if [ ${#sentence_chunks[@]} -gt 0 ]; then
          # Pour chaque chunk : 2× lecture avec pauses
          for chunk in "${sentence_chunks[@]}"; do
            pause=$(calc_pause "$chunk")
            pause_ms=$((pause * 1000))
            gap_ms=$((GAP_AFTER_REPEAT * 1000))
            PHASE2_TEXT="$PHASE2_TEXT $chunk [[slnc $pause_ms]] $chunk [[slnc $gap_ms]]"
          done
          # Récap : chunks back-to-back, lecture continue
          recap=$(printf '%s ' "${sentence_chunks[@]}")
          gap_ms=$((GAP_BETWEEN_SENTENCES * 1000))
          PHASE2_TEXT="$PHASE2_TEXT $recap [[slnc $gap_ms]]"
        fi
        sentence_chunks=()
      else
        sentence_chunks+=("$line")
      fi
    done < <(chunk_by_sentence "$TEXTE")

    # ── Construction du texte Phase 3 ────────────────────────────────────────
    PHASE3_TEXT="$INTRO_P3 [[slnc 1500]]"
    sentence_chunks=()
    while IFS= read -r line; do
      if [ "$line" = "[END_SENTENCE]" ]; then
        if [ ${#sentence_chunks[@]} -gt 0 ]; then
          recap=$(printf '%s ' "${sentence_chunks[@]}")
          PHASE3_TEXT="$PHASE3_TEXT $recap"
        fi
        sentence_chunks=()
      else
        sentence_chunks+=("$line")
      fi
    done < <(chunk_by_sentence "$TEXTE")
    PHASE3_TEXT="$PHASE3_TEXT [[slnc 1500]] $OUTRO"

    # ── Lecture des 3 phases ─────────────────────────────────────────────────
    "$SCRIPT_DIR/voix-prof.sh" "$MATIERE" "$INTRO_P1 [[slnc 1500]] $TEXTE" normal
    "$SCRIPT_DIR/voix-prof.sh" "$MATIERE" "$PHASE2_TEXT" langue
    "$SCRIPT_DIR/voix-prof.sh" "$MATIERE" "$PHASE3_TEXT" normal
    ;;

  # ════════════════════════════════════════════════════════════════════════════
  # BACKEND OpenAI : 1 MP3 par chunk + 1 par récap, concat ffmpeg
  # ════════════════════════════════════════════════════════════════════════════
  openai)
    if ! command -v ffmpeg &>/dev/null; then
      echo "[erreur] ffmpeg requis pour la dictée avec OpenAI." >&2
      echo "         Installe-le : brew install ffmpeg" >&2
      exit 4
    fi

    TMPDIR=$(mktemp -d -t dictee-prof)
    trap 'rm -rf "$TMPDIR"' EXIT

    # Cache des fichiers de silence (un par durée distincte)
    silence_file() {
      local sec="$1"
      local f="$TMPDIR/silence_${sec}.mp3"
      if [ ! -f "$f" ]; then
        ffmpeg -hide_banner -loglevel error -y \
          -f lavfi -i "anullsrc=r=24000:cl=mono" -t "$sec" -q:a 9 "$f"
      fi
      echo "$f"
    }

    # ── Phase 1 : intro + lecture intégrale, un seul appel ──────────────────
    OUTPUT_FILE="$TMPDIR/phase1.mp3" \
      "$SCRIPT_DIR/openai-tts-prof.sh" "$MATIERE" \
      "$INTRO_P1 ... $TEXTE" normal

    # ── Phase 2 : intro + chunks (×2) + recap par phrase ────────────────────
    OUTPUT_FILE="$TMPDIR/p2_intro.mp3" \
      "$SCRIPT_DIR/openai-tts-prof.sh" "$MATIERE" "$INTRO_P2" normal

    concat_list="$TMPDIR/concat.txt"
    : > "$concat_list"
    echo "file '$TMPDIR/p2_intro.mp3'" >> "$concat_list"
    echo "file '$(silence_file 2)'" >> "$concat_list"

    chunk_idx=0
    sent_idx=0
    sentence_chunks=()

    while IFS= read -r line; do
      if [ "$line" = "[END_SENTENCE]" ]; then
        if [ ${#sentence_chunks[@]} -gt 0 ]; then
          # Pour chaque chunk : 1 audio, joué 2× avec pauses
          for chunk in "${sentence_chunks[@]}"; do
            chunk_file="$TMPDIR/chunk_${chunk_idx}.mp3"
            OUTPUT_FILE="$chunk_file" \
              "$SCRIPT_DIR/openai-tts-prof.sh" "$MATIERE" "$chunk" langue

            pause=$(calc_pause "$chunk")
            echo "file '$chunk_file'" >> "$concat_list"
            echo "file '$(silence_file "$pause")'" >> "$concat_list"
            echo "file '$chunk_file'" >> "$concat_list"
            echo "file '$(silence_file $GAP_AFTER_REPEAT)'" >> "$concat_list"

            chunk_idx=$((chunk_idx + 1))
          done

          # Récap : 1 seul audio (phrase complète, tempo normal)
          recap_text=$(printf '%s ' "${sentence_chunks[@]}")
          recap_file="$TMPDIR/recap_${sent_idx}.mp3"
          OUTPUT_FILE="$recap_file" \
            "$SCRIPT_DIR/openai-tts-prof.sh" "$MATIERE" "$recap_text" normal

          echo "file '$recap_file'" >> "$concat_list"
          echo "file '$(silence_file $GAP_BETWEEN_SENTENCES)'" >> "$concat_list"

          sent_idx=$((sent_idx + 1))
        fi
        sentence_chunks=()
      else
        sentence_chunks+=("$line")
      fi
    done < <(chunk_by_sentence "$TEXTE")

    # Concat Phase 2 (re-encodage pour uniformiser les formats)
    ffmpeg -hide_banner -loglevel error -y \
      -f concat -safe 0 -i "$concat_list" \
      -c:a libmp3lame -b:a 64k -ar 24000 -ac 1 \
      "$TMPDIR/phase2.mp3"

    # ── Phase 3 : intro + relecture en chunks continus + outro ──────────────
    p3_text="$INTRO_P3"
    sentence_chunks=()
    while IFS= read -r line; do
      if [ "$line" = "[END_SENTENCE]" ]; then
        if [ ${#sentence_chunks[@]} -gt 0 ]; then
          recap=$(printf '%s ' "${sentence_chunks[@]}")
          p3_text="$p3_text $recap"
        fi
        sentence_chunks=()
      else
        sentence_chunks+=("$line")
      fi
    done < <(chunk_by_sentence "$TEXTE")
    p3_text="$p3_text $OUTRO"

    OUTPUT_FILE="$TMPDIR/phase3.mp3" \
      "$SCRIPT_DIR/openai-tts-prof.sh" "$MATIERE" "$p3_text" normal

    # ── Lecture séquentielle ────────────────────────────────────────────────
    afplay "$TMPDIR/phase1.mp3"
    sleep 1
    afplay "$TMPDIR/phase2.mp3"
    sleep 1
    afplay "$TMPDIR/phase3.mp3"
    ;;

  # ════════════════════════════════════════════════════════════════════════════
  # Fallback texte
  # ════════════════════════════════════════════════════════════════════════════
  text)
    echo ""
    echo "[Dictée — voix indisponible, texte uniquement]"
    echo ""
    echo "── 1. Lecture intégrale ──"
    echo "$TEXTE"
    echo ""
    echo "── 2. Dictée par groupes de souffle (× 2 + récap) ──"
    sent_idx=0
    sentence_chunks=()
    while IFS= read -r line; do
      if [ "$line" = "[END_SENTENCE]" ]; then
        if [ ${#sentence_chunks[@]} -gt 0 ]; then
          sent_idx=$((sent_idx + 1))
          echo "Phrase $sent_idx :"
          for chunk in "${sentence_chunks[@]}"; do
            echo "  • $chunk  (× 2)"
          done
          echo "  → Récap : $(printf '%s ' "${sentence_chunks[@]}")"
          echo ""
        fi
        sentence_chunks=()
      else
        sentence_chunks+=("$line")
      fi
    done < <(chunk_by_sentence "$TEXTE")
    echo "── 3. Relecture finale ──"
    echo "$TEXTE"
    echo ""
    ;;
esac
