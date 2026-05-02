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

Sur macOS, **chaque matière a sa propre voix** pour incarner un prof différent. Le helper `scripts/say-prof.sh` choisit la bonne voix et le bon débit selon la matière, et règle aussi la prosodie (ralenti pour insister, accéléré pour un récap, très lent pour modéliser une prononciation).

| Matière | Persona | Voix utilisée (avec premium) | Fallback (sans premium) |
|---|---|---|---|
| Français | Mme Audrey | Audrey (Premium) | Thomas |
| Mathématiques | M. Jacques | Thomas (Premium) ou Jacques | Thomas |
| Histoire-Géographie | Mme Aurélie | Aurélie | Thomas |
| SVT | Mme Marie | Marie | Thomas |
| Physique-Chimie | M. Thomas | Thomas (Premium) | Thomas |
| Anglais | Mr. Daniel | Ava (Premium) ou Evan (Premium) | Daniel |
| Allemand | Frau Anna | Anna (Premium) | Anna |
| Technologie | M. Thomas | Thomas (Premium) | Thomas |

#### Installer les voix premium (recommandé)

Les voix par défaut macOS (Thomas, Daniel, Anna) restent un peu robotiques. Les voix **Premium / Neural** sont nettement plus naturelles et expressives — elles font une vraie différence pour la perception "prof humain".

1. **Réglages système** > **Accessibilité** > **Contenu énoncé**
2. Cliquer sur **Voix système** > menu **Voix**
3. Sélectionner **Personnaliser…** en bas de la liste
4. Cocher les voix souhaitées (chercher « Premium » ou « Neural ») :
   - Français : `Audrey (Premium)`, `Aurélie`, `Marie`, `Thomas (Premium)`
   - Anglais : `Ava (Premium)`, `Evan (Premium)`, `Tom (Premium)`
   - Allemand : `Anna (Premium)`, `Markus`, `Petra`
5. macOS télécharge en arrière-plan (~100-500 Mo par voix). Une fois installées, le helper les détecte automatiquement.

> **Sur Linux et Windows**, cette fonctionnalité n'est pas disponible. Le skill reste en mode texte.

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