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

### Micro en direct (STT)

L'élève peut parler dans son micro et soumettre la transcription au professeur :

```bash
# Depuis le dossier du skill :
./scripts/record-and-transcribe.sh 30 fr   # 30 secondes, français
./scripts/record-and-transcribe.sh 45 en   # 45 secondes, anglais
./scripts/record-and-transcribe.sh 30 de   # 30 secondes, allemand
```

Le script installe automatiquement `ffmpeg` (via Homebrew) et `whisper` (via pip) au premier lancement.

### Permissions Claude Code

Quand le professeur utilise `say` ou le script d'enregistrement, Claude Code demande une confirmation avant d'exécuter la commande. Deux façons de gérer ça :

**Option 1 — Approuver au fil de l'eau**
Claude Code affiche un prompt à chaque appel. Répondre **"Always allow"** au premier pour ne plus être interrompu ensuite.

**Option 2 — Pré-autoriser dans les réglages Claude Code**
Ajouter `say` et `scripts/record-and-transcribe.sh` à la liste des commandes autorisées dans les paramètres de Claude Code pour éviter tout prompt dès le départ.

> Le skill ne peut pas pré-autoriser ces permissions lui-même — c'est le système de sécurité de Claude Code qui les gère, pas le skill.

## Licence

Apache 2.0