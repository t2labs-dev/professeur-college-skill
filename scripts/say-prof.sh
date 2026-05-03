#!/usr/bin/env bash
# say-prof.sh — Lit un texte avec la voix et la prosodie du prof de la matière
#
# Usage:
#   ./scripts/say-prof.sh <matière> "<texte>" [style]
#
# Matières  : francais, maths, histoire, svt, physique, anglais, allemand, techno
# Style     : normal (défaut) | important | rapide | langue
#   - normal     : débit pédagogique standard
#   - important  : ralenti + pauses, pour insister sur un point clé
#   - rapide     : pour un récap ou une révision de notions connues
#   - langue     : très lent et articulé, pour modéliser une prononciation
#
# Le texte peut contenir des marqueurs de prosodie macOS :
#   [[slnc 600]]    pause de 600 ms
#   [[rate 150]]    change le débit en cours
#   [[emph +]]      emphase (mot suivant)
#   [[char LTRL]]   épelle (utile pour orthographe)
#
# Exemples :
#   ./scripts/say-prof.sh francais "Bonjour ! Voyons ensemble ce poème."
#   ./scripts/say-prof.sh maths "Le théorème de Pythagore [[slnc 400]] s'applique aux triangles rectangles." important
#   ./scripts/say-prof.sh anglais "I would have done it." langue

set -euo pipefail

MATIERE="${1:-francais}"
TEXTE="${2:-}"
STYLE="${3:-normal}"

if [ -z "$TEXTE" ]; then
  echo "Usage: $0 <matière> \"<texte>\" [style]" >&2
  echo "       Styles : normal | important | rapide | langue" >&2
  exit 1
fi

# ── Détection des voix installées ─────────────────────────────────────────────
voice_exists() {
  say -v '?' 2>/dev/null | grep -qE "^${1//(/\\(}"
}

# Choisit la première voix disponible dans la liste fournie
pick_voice() {
  for v in "$@"; do
    if voice_exists "$v"; then
      echo "$v"
      return
    fi
  done
  # Si rien ne matche, retourne le dernier (la voix par défaut système)
  echo "$1"
}

# ── Mapping matière → voix (premium d'abord, puis fallbacks) ──────────────────
case "$MATIERE" in
  francais|français)
    VOIX=$(pick_voice "Audrey (Premium)" "Audrey (Enhanced)" "Aurélie" "Marie" "Audrey" "Thomas")
    BASE_RATE=175
    PERSONA="Mme Audrey, prof de français — chaleureuse, expressive"
    ;;
  maths|mathematiques|mathématiques)
    VOIX=$(pick_voice "Thomas (Premium)" "Jacques" "Thomas")
    BASE_RATE=165   # posé, pour les démonstrations
    PERSONA="M. Jacques, prof de maths — posé, rigoureux"
    ;;
  histoire|histoire-geographie|histoire-geographie|histoire-geo|hg)
    VOIX=$(pick_voice "Aurélie" "Marie" "Audrey (Premium)" "Audrey (Enhanced)" "Sandy (Français (France))" "Thomas")
    BASE_RATE=175   # rythme conteur
    PERSONA="Mme Aurélie, prof d'histoire-géo — narrative, posée"
    ;;
  svt)
    VOIX=$(pick_voice "Marie" "Audrey (Premium)" "Audrey (Enhanced)" "Shelley (Français (France))" "Thomas")
    BASE_RATE=170
    PERSONA="Mme Marie, prof de SVT — curieuse, précise"
    ;;
  physique|physique-chimie)
    VOIX=$(pick_voice "Thomas (Premium)" "Reed (Français (France))" "Thomas")
    BASE_RATE=165   # ralenti pour les formules
    PERSONA="M. Thomas, prof de physique-chimie — méthodique"
    ;;
  anglais|english|lv1)
    VOIX=$(pick_voice "Ava (Premium)" "Evan (Premium)" "Tom (Premium)" "Daniel" "Karen")
    BASE_RATE=160   # plus lent pour la LV
    PERSONA="Mr. Daniel, English teacher — clear, encouraging"
    ;;
  allemand|deutsch|lv2)
    VOIX=$(pick_voice "Anna (Premium)" "Anna (Enhanced)" "Markus" "Petra" "Anna")
    BASE_RATE=150   # encore plus lent (LV2, phonétique)
    PERSONA="Frau Anna, Deutschlehrerin — deutlich, ruhig"
    ;;
  techno|technologie)
    VOIX=$(pick_voice "Thomas (Premium)" "Jacques" "Thomas")
    BASE_RATE=170
    PERSONA="M. Thomas, prof de techno — concret, pratique"
    ;;
  *)
    echo "[avertissement] Matière inconnue : $MATIERE — utilisation de la voix par défaut" >&2
    VOIX="Thomas"
    BASE_RATE=175
    PERSONA="Prof par défaut"
    ;;
esac

# ── Application du style sur le débit ─────────────────────────────────────────
case "$STYLE" in
  normal)
    RATE=$BASE_RATE
    ;;
  important)
    RATE=$((BASE_RATE - 30))    # ralenti pour insister
    # Préfixe d'une petite pause pour attirer l'attention
    TEXTE="[[slnc 300]] $TEXTE"
    ;;
  rapide)
    RATE=$((BASE_RATE + 25))    # accéléré pour un récap
    ;;
  langue)
    RATE=$((BASE_RATE - 50))    # très lent, pour modéliser
    ;;
  *)
    # Si l'utilisateur passe un nombre brut, on le respecte
    if [[ "$STYLE" =~ ^[0-9]+$ ]]; then
      RATE=$STYLE
    else
      RATE=$BASE_RATE
    fi
    ;;
esac

# ── Lecture ───────────────────────────────────────────────────────────────────
say -v "$VOIX" -r "$RATE" "$TEXTE"