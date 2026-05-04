# scripts/_venv.sh — venv local au skill, partagé par les scripts Python
#
# Source-le depuis les autres scripts ; il expose :
#   $VENV_DIR / $VENV_PY / $VENV_PIP   — chemins absolus
#   ensure_packages "<test_imports>" <pkg> [pkg...]   — installe si manquant
#
# Le venv est créé dans <skill_root>/.venv/ au premier appel et n'est jamais
# committé (cf. .gitignore). Évite la pollution du Python global et contourne
# PEP 668 (externally-managed-environment) sur macOS récent.

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$SKILL_ROOT/.venv"
VENV_PY="$VENV_DIR/bin/python3"
VENV_PIP="$VENV_DIR/bin/pip3"

ensure_venv() {
  if [ ! -x "$VENV_PY" ]; then
    if ! command -v python3 &>/dev/null; then
      echo "[erreur] python3 requis. brew install python3" >&2
      return 1
    fi
    echo "[info] Création du venv local : $VENV_DIR"
    python3 -m venv "$VENV_DIR"
    "$VENV_PY" -m pip install --quiet --upgrade pip
  fi
}

# ensure_packages "<test_imports>" <pkg> [pkg...]
#   test_imports : code Python qui doit s'importer sans erreur si tout est là
#                  (ex: "import whisper" ou "import transformers, torch")
#   pkg...       : noms pip à installer si l'import échoue
ensure_packages() {
  ensure_venv || return 1
  local check="$1"
  shift
  if ! "$VENV_PY" -c "$check" 2>/dev/null; then
    echo "[info] Installation dans le venv : $*"
    "$VENV_PIP" install --quiet "$@" || {
      echo "[erreur] Échec de l'installation. Réessaie manuellement :" >&2
      echo "         $VENV_PIP install $*" >&2
      return 1
    }
  fi
}
