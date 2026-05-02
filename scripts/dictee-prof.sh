#!/usr/bin/env bash
# dictee-prof.sh — Dictée structurée à voix haute
#
# Usage:
#   ./scripts/dictee-prof.sh <matière> "<texte complet>" [pause_ecriture_secondes]
#
# Workflow pédagogique (norme Éducation nationale) :
#   1. Lecture intégrale au débit normal-lent (contextualisation)
#   2. Pour chaque phrase :
#       a. Lecture lente
#       b. Pause d'écriture adaptée à la longueur (~1 s/mot, min 2 s, max 8 s)
#       c. Relecture lente (fixe l'orthographe)
#       d. Courte pause de 1 s avant la phrase suivante
#   3. Relecture intégrale finale (vérification)
#
# Si pause_ecriture_secondes est passé, il remplace la pause auto-calculée.
#
# Backend automatique via voix-prof.sh :
#   - OpenAI TTS si clé configurée (qualité quasi-humaine)
#   - macOS `say` sinon
#   - Texte écrit en dernier recours (mais peu utile pour une dictée…)

set -euo pipefail

MATIERE="${1:-francais}"
TEXTE="${2:-}"
PAUSE_OVERRIDE="${3:-}"

if [ -z "$TEXTE" ]; then
  echo "Usage: $0 <matière> \"<texte>\" [pause_ecriture_secondes]" >&2
  echo "       Ex   : $0 francais \"Le chat dort sur le tapis. Il rêve de souris.\"" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOIX="$SCRIPT_DIR/voix-prof.sh"

# ── Pause d'écriture adaptée à la longueur de la phrase ──────────────────────
calc_pause() {
  local words
  words=$(echo "$1" | wc -w | tr -d ' ')
  local p=$words            # ~1 s par mot (l'élève écrit pendant la lecture aussi)
  [ "$p" -lt 2 ] && p=2
  [ "$p" -gt 8 ] && p=8
  echo "$p"
}

# ── Phase 1 : lecture intégrale (contextualisation) ───────────────────────────
"$VOIX" "$MATIERE" "Voici le texte de la dictée. Première lecture en entier, écoute attentivement." normal
"$VOIX" "$MATIERE" "$TEXTE" normal
sleep 1

# ── Phase 2 : annonce de la dictée phrase par phrase ──────────────────────────
"$VOIX" "$MATIERE" "Maintenant je dicte phrase par phrase. Je lis chaque phrase deux fois." normal

# ── Phase 3 : dictée phrase par phrase (lecture × 2 + pause d'écriture) ───────
while IFS= read -r phrase; do
  phrase=$(echo "$phrase" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
  [ -z "$phrase" ] && continue

  if [ -n "$PAUSE_OVERRIDE" ]; then
    pause="$PAUSE_OVERRIDE"
  else
    pause=$(calc_pause "$phrase")
  fi

  "$VOIX" "$MATIERE" "$phrase" langue
  sleep "$pause"
  "$VOIX" "$MATIERE" "$phrase" langue
  sleep 1
done < <(echo "$TEXTE" | sed -E 's/([.!?])[[:space:]]*/\1\n/g')

# ── Phase 4 : relecture intégrale (vérification) ──────────────────────────────
"$VOIX" "$MATIERE" "Relecture finale pour que tu vérifies ta copie." normal
"$VOIX" "$MATIERE" "$TEXTE" normal
"$VOIX" "$MATIERE" "Voilà. Tu peux relire ta copie tranquillement." normal
