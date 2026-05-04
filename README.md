# professeur-college

Professeur de collège virtuel (6e–3e) couvrant 8 matières — cours, devoirs, exercices, fiches de révision et oral — selon les programmes officiels de l'Éducation nationale française.

## Installation

```bash
npx skills add t2labs-dev/professeur-college-skill
```

## Utilisation

Une fois installé, le skill s'active automatiquement dès qu'une question scolaire de niveau collège est détectée. Pas besoin de l'appeler explicitement.

**Exemples de déclenchement :**

```
Mon fils est en 4e, il bloque sur les fractions
Comment on analyse un poème ?
Peux-tu me donner des exercices sur le théorème de Pythagore ?
Fiche de révision sur la Révolution française niveau 4e
J'ai mon oral du brevet dans 10 jours, fais-moi une simulation
```

### Matières couvertes

| Matière | Niveaux |
|---|---|
| Français | 6e – 3e |
| Mathématiques | 6e – 3e |
| Histoire-Géographie | 6e – 3e |
| SVT | 6e – 3e |
| Physique-Chimie | 5e – 3e |
| Anglais (LV1) | 6e – 3e |
| Allemand (LV2) | 5e – 3e |
| Technologie | 6e – 3e |

### Modes disponibles

- **Aide aux devoirs** — méthode socratique, sans donner la réponse directement
- **Explication de cours** — pour comprendre une notion non acquise
- **Exercices et corrigés** — entraînement avec correction détaillée
- **Fiche de révision** — fiche structurée à imprimer ou conserver
- **Oral** — préparation, simulation de jury, analyse audio

## Capacités vocales (macOS uniquement)

### Pré-requis système

Selon les fonctionnalités utilisées :

| Fonctionnalité | Outil système | Paquets Python (venv local) | Modèle ML |
|---|---|---|---|
| Dictée avec backend OpenAI (`dictee-prof.sh`) | `ffmpeg` | — | — |
| Transcription micro (`record-and-transcribe.sh`) | `ffmpeg` + `whisper-cpp` | — | GGML small ~466 Mo |
| Diagnostic phonétique fin (`prononciation-prof.sh`) | `ffmpeg` + `espeak-ng` | `transformers`, `torch`, `soundfile`, `phonemizer` (~1.5 Go) | wav2vec2 ~1 Go |
| Voix `say` (sans dictée OpenAI) | — (déjà sur macOS) | — | — |

```bash
brew install ffmpeg whisper-cpp espeak-ng    # outils système (Homebrew : https://brew.sh)
```

**Isolation des deps** : aucune installation globale de paquets Python. Les paquets pour `prononciation-prof.sh` sont installés dans un virtualenv local (`<skill>/.venv/`), et le modèle whisper.cpp dans `<skill>/.models/`. Les deux dossiers sont gitignorés et créés à la volée au premier lancement. Aucune pollution du Python système, contournement automatique de PEP 668 (« externally-managed-environment ») sur macOS récent.

### Voix du professeur (TTS)

Chaque matière a **son propre prof avec sa propre voix**. L'orchestrateur `scripts/voix-prof.sh` sélectionne automatiquement le meilleur backend disponible :

| Backend | Quand | Qualité | Coût |
|---|---|---|---|
| **OpenAI TTS** | Si `OPENAI_API_KEY` est configurée | ⭐⭐⭐ Quasi-humaine | ~$0.03/1k caractères |
| **macOS `say`** | Sur Mac sans clé OpenAI | ⭐⭐ Correcte (⭐⭐⭐ avec voix premium) | Gratuit |
| **Texte écrit** | Linux/Windows sans clé | — | Gratuit |

#### Quand le prof utilise sa voix — 3 cas seulement

La voix n'est pas activée en permanence. Le skill l'utilise uniquement pour :
1. **Capter l'attention** de l'élève (courte phrase d'accroche).
2. **Dicter un texte en français** (orthographe, récitation, mémorisation). Pour une vraie dictée notée, le skill utilise `scripts/dictee-prof.sh` qui structure la lecture (intégrale → phrase par phrase lue 2 fois avec pauses d'écriture → relecture finale).
3. **Montrer la bonne prononciation** en langue étrangère (anglais, allemand).

Pour tout le reste (explications, corrections, fiches), le skill reste en texte écrit.

#### Mapping matière → persona

| Matière | Persona | Voix OpenAI | Voix macOS (avec premium) |
|---|---|---|---|
| Français | Mme Audrey | `nova` | Audrey (Premium) |
| Mathématiques | M. Jacques | `onyx` | Thomas (Premium) ou Jacques |
| Histoire-Géographie | Mme Aurélie | `shimmer` | Aurélie |
| SVT | Mme Marie | `coral` | Marie |
| Physique-Chimie | M. Thomas | `echo` | Thomas (Premium) |
| Anglais | Mr. Daniel | `fable` | Ava (Premium) ou Evan (Premium) |
| Allemand | Frau Anna | `sage` | Anna (Premium) |
| Technologie | M. Thomas | `alloy` | Thomas (Premium) |

#### Configuration OpenAI (recommandé pour la qualité)

Pour activer le backend OpenAI, fournis une clé API par **l'une** de ces 3 méthodes (priorité décroissante) :

**1. Variable d'environnement** (la plus simple)
```bash
export OPENAI_API_KEY="sk-..."
```
Ajoute la ligne à ton `~/.zshrc` ou `~/.bashrc` pour la rendre permanente.

**2. Fichier utilisateur**
```bash
mkdir -p ~/.config/professeur-college
echo "sk-..." > ~/.config/professeur-college/openai-key
chmod 600 ~/.config/professeur-college/openai-key
```

**3. Fichier dans le skill** (gitignored)
```bash
echo "sk-..." > <dossier-du-skill>/.openai-key
```

Une fois la clé en place, le skill l'utilise automatiquement à la prochaine invocation. Aucun autre paramétrage requis.

> Coût indicatif : une session de 30 min utilise rarement plus de 5-10 phrases de voix (les 3 règles ci-dessus limitent l'usage). Compte **moins de 1 centime par session**.

#### Installer les voix premium macOS (alternative gratuite)

Si tu préfères ne pas utiliser OpenAI, les voix **Premium / Neural** macOS améliorent nettement le rendu de `say` (la voix par défaut Thomas reste un peu robotique).

1. **Réglages système** > **Accessibilité** > **Contenu énoncé**
2. Cliquer sur **Voix système** > menu **Voix** > **Personnaliser…**
3. Cocher les voix souhaitées :
   - Français : `Audrey (Premium)`, `Aurélie`, `Marie`, `Thomas (Premium)`
   - Anglais : `Ava (Premium)`, `Evan (Premium)`, `Tom (Premium)`
   - Allemand : `Anna (Premium)`, `Markus`, `Petra`
4. macOS télécharge en arrière-plan (~100-500 Mo par voix). Le helper détecte automatiquement les voix installées.

> **Sur Linux et Windows sans clé OpenAI**, le skill bascule en mode texte uniquement.

#### Forcer un backend (debug / test)

Pour bypasser la détection automatique, exporte la variable d'env `PROF_BACKEND` avec `say`, `openai` ou `text` :

```bash
PROF_BACKEND=say ./scripts/voix-prof.sh francais "Test avec say."
PROF_BACKEND=text ./scripts/dictee-prof.sh francais "Aperçu sans audio."
```

### Micro en direct (STT)

L'élève peut parler dans son micro et soumettre la transcription au professeur :

```bash
# Depuis le dossier du skill :
./scripts/record-and-transcribe.sh 30 fr   # 30 secondes, français
./scripts/record-and-transcribe.sh 45 en   # 45 secondes, anglais
./scripts/record-and-transcribe.sh 30 de   # 30 secondes, allemand
```

Implémentation : **whisper.cpp** (port C++ natif, accélération Metal sur Apple Silicon, 2-5× plus rapide que `openai-whisper` Python). Pré-requis :
```bash
brew install ffmpeg whisper-cpp
```
Le modèle GGML (`small` par défaut, ~466 Mo) est téléchargé au premier lancement dans `<skill>/.models/`. Pour un autre modèle :
```bash
WHISPER_MODEL=tiny ./scripts/record-and-transcribe.sh 30 fr     # ~75 Mo, plus rapide, moins précis
WHISPER_MODEL=medium ./scripts/record-and-transcribe.sh 30 fr   # ~1.5 Go, plus précis
```

### Diagnostic de prononciation (langues étrangères)

Whisper transcrit en texte et « corrige silencieusement » les erreurs phonétiques (« tree » prononcé pour « three » est souvent normalisé). Pour un diagnostic phonétique réel en anglais ou allemand, le skill utilise `prononciation-prof.sh` qui extrait les phonèmes effectivement prononcés via **wav2vec2-phoneme** (modèle Meta local) et les compare aux phonèmes cibles via **espeak-ng** :

```bash
./scripts/prononciation-prof.sh "think" en       # 5s par défaut
./scripts/prononciation-prof.sh "I would have known" en 6
./scripts/prononciation-prof.sh "ich möchte" de 4
```

Sortie type :
```
Texte cible        : think
Phonèmes cibles    : /θ ɪ ŋ k/
Phonèmes prononcés : /s ɪ ŋ k/

Écarts :
  /θ/ → /s/   substitution
```

Le prof interprète le diff (substitution `/θ/→/s/` est l'erreur classique L1 français → explication position de la langue, re-modélisation TTS).

**Pré-requis** :
```bash
brew install ffmpeg espeak-ng    # système
```
Les paquets Python (`transformers`, `torch`, `soundfile`, `phonemizer`, ~1.5 Go) sont installés automatiquement dans le venv local au premier lancement. Le modèle `facebook/wav2vec2-lv-60-espeak-cv-ft` (~1 Go) est téléchargé au premier appel et caché dans `~/.cache/huggingface/`. À utiliser **en zoom ponctuel** quand la prononciation d'un mot précis pose problème, pas en boucle systématique.

### Permissions Claude Code

Quand le professeur utilise `say` ou le script d'enregistrement, Claude Code demande une confirmation avant d'exécuter la commande. Deux façons de gérer ça :

**Option 1 — Approuver au fil de l'eau**
Claude Code affiche un prompt à chaque appel. Répondre **"Always allow"** au premier pour ne plus être interrompu ensuite.

**Option 2 — Pré-autoriser dans les réglages Claude Code**
Ajouter `say`, `scripts/record-and-transcribe.sh` et `scripts/prononciation-prof.sh` à la liste des commandes autorisées dans les paramètres de Claude Code pour éviter tout prompt dès le départ.

> Le skill ne peut pas pré-autoriser ces permissions lui-même — c'est le système de sécurité de Claude Code qui les gère, pas le skill.

## Migration depuis une version antérieure

Si une version précédente du skill avait installé `openai-whisper` dans ton Python global (via `pip3 install openai-whisper`), ces paquets restent en place mais **ne sont plus utilisés** par la version actuelle :
- `record-and-transcribe.sh` utilise désormais le binaire C++ `whisper-cpp` (à installer via Homebrew).
- `prononciation-prof.sh` installe ses paquets Python (`transformers`, `torch`, …) dans un venv local au skill (`<skill>/.venv/`), pas en global.

Aucun conflit, mais ~700 Mo de paquets orphelins sur ton disque. Pour récupérer l'espace :

```bash
pip3 uninstall -y openai-whisper torch
# Sur macOS récent (PEP 668), si pip refuse : pip3 uninstall --break-system-packages -y openai-whisper torch
```

Si tu veux aussi nettoyer un éventuel venv local créé par une version intermédiaire de transition :
```bash
rm -rf <chemin-vers-le-skill>/.venv
```

## Licence

Apache 2.0