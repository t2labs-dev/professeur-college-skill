# Mode conversation parlée (anglais, allemand)

Pratique orale interactive boucle TTS prof ↔ STT élève. **Réservé aux LV** (anglais, allemand) — le français reste sur les 3 règles voix par défaut.

## Quand proposer ce mode

Propose-le explicitement à l'élève dans ces situations :
- L'élève demande de l'aide en anglais/allemand et doit travailler l'oral (cours sur EOC/EOI, contrôle d'oral, prépa brevet anglais).
- L'élève dit qu'il veut « pratiquer », « parler », « s'entraîner à l'oral », ou évoque l'oral du brevet/contrôle continu.
- L'élève te répond à une question écrite par une demande implicite de pratique (« je sais pas dire ça à l'oral »).

**Ne l'active jamais sans demander.** Formule type : *« Tu veux qu'on passe en mode conversation parlée ? Je te parlerai en anglais, tu répondras à voix haute, je corrigerai prononciation et grammaire. »*

## Pré-flight permissions (une fois par session)

Claude Code demande la permission pour chaque commande nouvelle. Pour éviter d'interrompre la pratique 20 fois, **prévenir l'élève dès l'acceptation du mode** :

> *« Claude Code va me demander 2 autorisations dès qu'on commence : une pour parler (`voix-prof.sh`), une pour t'enregistrer (`record-and-transcribe.sh`). Choisis "Always allow" sur chaque, après ça on enchaîne sans interruption. »*

Puis lance immédiatement, dans cet ordre, **un seul appel chacun** :
1. Phrase d'accroche TTS (déclenche permission `voix-prof.sh` / `say` / `afplay`) :
   ```bash
   ./scripts/voix-prof.sh anglais "Hi! Let's practice. Ready?" langue
   ```
2. Premier enregistrement court (déclenche permission `record-and-transcribe.sh` / `ffmpeg` / `whisper`) :
   ```bash
   ./scripts/record-and-transcribe.sh 5 en
   ```

Une fois les deux « Always allow » donnés, la pratique tourne sans prompt.

## 4 sous-modes

Choisis selon ce que veut travailler l'élève. **Drill** ou **Scénarios** sont la porte d'entrée par défaut.

### 1. Drill questions (warmup, automatismes)

Q→R courtes pour automatiser une structure (temps verbal, question word, vocabulaire d'un champ lexical). 5-10 échanges, ~3 secondes par réponse.

**Exemple** (A1, simple present + family) :
- "What's your name?" → "How old are you?" → "Do you have brothers or sisters?" → "What does your father do?"

**Exemple** (A2, simple past) :
- "What did you do yesterday?" → "Where did you go last weekend?" → "What was the last film you watched?"

Boucle :
```
voix-prof.sh anglais "What did you do yesterday?" langue
record-and-transcribe.sh 8 en   # ~8s pour une phrase courte
# → analyse rapide (2 lignes max), question suivante
```

### 2. Scénarios calibrés (mode principal)

Mise en situation du programme officiel collège. Le prof joue un rôle (vendeur, hôte, copain), l'élève joue le sien. 5-8 répliques par scénario.

**Banque A1 (6e/5e)** :
- *Introducing yourself* — name, age, country, family, hobby
- *Ordering at a café* — drink, food, price, please/thank you
- *Asking the way* — où est X ?, à gauche/droite, merci
- *At school* — favourite subject, what time, school day
- *In a shop* — colour, size, price, can I have

**Banque A2 (4e/3e)** :
- *Past holiday* — where, with whom, how long, what did you do, would you go back
- *Future plans* — going to vs will, weekend, after school
- *Giving an opinion* — film, book, sport, justification simple
- *Job interview / school presentation* — strengths, why you, an example
- *Solving a problem* — lost something, missed train, asking for help

**Allemand A1/A2** : équivalents — *sich vorstellen, im Café, nach dem Weg fragen, in der Schule, am Wochenende, Ferien beschreiben*.

Avant de démarrer un scénario, annonce le contexte en 1 phrase (en français), puis enchaîne en langue cible.

### 3. Lecture à voix haute (variante)

Texte court (3-6 phrases) du manuel ou choisi par le prof. L'élève le lit, le prof analyse prononciation et fluidité.

```
# Le prof affiche le texte en clair (pas de TTS), demande à l'élève de le lire
record-and-transcribe.sh 30 en
# Analyse : compare la transcription Whisper au texte source
# Re-modèle les mots difficiles via TTS
voix-prof.sh anglais "thought" langue
```

Indicateurs Whisper exploitables :
- Mots manquants dans la transcription → probablement non prononcés ou marmonnés
- Mots inattendus → substitution phonétique (ex: « three » lu /tri:/ devient « tree »)
- Transcription correcte mais segmentation étrange → débit / pauses

### 4. Conversation libre (sur demande)

Si l'élève demande *« on peut juste discuter ? »* → choisir un thème adapté niveau (weekend, school, hobbies, holidays, family) et poser une question ouverte. Pas de scénario rigide, mais correction toujours active.

## Grille de correction (après chaque réponse élève)

Format de feedback **court** (3-5 lignes max), pour ne pas casser le rythme :

| Axe | Quoi corriger | Comment |
|---|---|---|
| **Grammaire** | Erreur de temps, ordre des mots, accord, auxiliaire manquant | Donner la règle en 1 phrase + reformulation correcte |
| **Vocabulaire** | Faux-ami, mot français traduit littéralement, registre | Mot juste + 1 exemple |
| **Prononciation** | Phonèmes critiques EN : `th` /θ/ /ð/, voyelles longues, -ed /t/ /d/ /ɪd/, accent tonique. Phonèmes critiques DE : `r`, `ch` (ich-Laut/ach-Laut), umlauts, déclinaison à l'oreille | Re-modèle le mot via TTS (`voix-prof.sh ... langue`) + transcription simplifiée |
| **Fluidité** | Hésitations, blancs longs, mots manquants à la transcription | Encourager, proposer une formule de remplissage (« well… », « let me think ») |

**Limites de Whisper** : la transcription convertit en texte, donc la prononciation fine n'est pas directement visible. Utiliser des **proxys** : mots manquants (marmonnés ?), mots inattendus (substitution phonétique). Être honnête : *« Whisper a compris X, vérifie ta prononciation de Y. »*

**Priorité de correction** (ne pas tout corriger d'un coup) :
1. Si le message ne passe pas → grammaire/vocab d'abord
2. Si le message passe → prononciation (le point faible récurrent en collège)
3. Fluidité en feedback global, pas à chaque tour

## Boucle d'interaction type

```
[Prof] voix-prof.sh anglais "<question/réplique>" langue
[Élève] record-and-transcribe.sh <durée> en
[Prof] analyse 3-5 lignes (ce qui marche, 1 ou 2 corrections, mot re-modélisé si besoin)
[Prof] question/réplique suivante
```

**Durées d'enregistrement** indicatives :
- Drill (réponse courte) : 5-8s
- Scénario (réplique) : 10-15s
- Lecture à voix haute (3-6 phrases) : 25-40s
- Conversation libre : 20-30s

## Sortie du mode

Après 5-15 échanges (selon fatigue de l'élève), proposer une **synthèse** : 3 points forts, 2 points à retravailler avec rappel de règle, suggestion d'exercice écrit en suivi. Puis sortir du mode oral et revenir au texte par défaut.
