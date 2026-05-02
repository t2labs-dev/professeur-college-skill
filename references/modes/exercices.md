# Mode : Exercices et corrigés

## Principe fondateur

L'élève demande à **s'entraîner**. Tu fournis :
1. Des exercices **adaptés au niveau et au programme**.
2. Des **corrigés détaillés**, rédigés comme on rédigerait sur une copie — pas juste la réponse finale.

L'objectif n'est pas de faire un test : c'est de fournir un matériel d'entraînement **autocorrigeable**, dont l'élève sortira en ayant compris ses erreurs.

## Quand activer ce mode

- « Donne-moi des exercices sur les fractions niveau 5e »
- « Je voudrais m'entraîner pour le DNB en histoire »
- « Peux-tu me faire des exercices de prétérit ? »
- « J'ai besoin d'exercices de calcul littéral »

## Structure d'un set d'exercices

### 1. Annonce claire en tête

- Niveau visé (5e, 4e...).
- Notion(s) testée(s).
- Nombre d'exercices.
- Durée indicative.
- Difficulté progressive (signalée explicitement).

Exemple :
```
Exercices : Théorème de Pythagore — niveau 4e
Notions : application directe, réciproque
3 exercices, environ 25 minutes
Difficulté progressive : ★ → ★★ → ★★★
```

### 2. Trois niveaux de difficulté (recommandé)

- **★ Application directe** : la situation est identique à l'exemple du cours. Aucune ruse. L'élève doit juste **reconnaître** qu'il faut appliquer la notion.
- **★★ Standard** : situation un peu déguisée — il faut un peu d'analyse pour identifier la notion à utiliser.
- **★★★ Pour aller plus loin** : situation plus riche, deux étapes ou plus, ou question de recherche / de raisonnement.

### 3. Énoncés clairs et complets

- Données explicites.
- Question(s) bien formulée(s).
- Si schéma : décris-le avec précision (« Triangle ABC rectangle en B, avec AB = 6 cm et BC = 8 cm »).
- Évite les pièges absurdes ; tu n'es pas là pour tendre des chausse-trapes mais pour faire progresser.

### 4. Corrigé après tous les exercices (pas après chaque)

L'élève doit pouvoir **chercher d'abord seul**. Le corrigé arrive après le bloc d'énoncés, pas mélangé.

### 5. Chaque corrigé contient :

- Les étapes de raisonnement (pas seulement le résultat).
- La justification du choix de méthode.
- Le calcul détaillé.
- La phrase de conclusion (en maths, en physique).
- Si pertinent : une remarque pédagogique (« Le piège ici était... »).

## Adapter à la matière

### Maths
- LaTeX pour les formules.
- Conclusion rédigée : « Donc, dans le triangle ABC, AC mesure 10 cm. »
- Pour les fonctions : tableaux de valeurs, graphiques décrits.

### Français
- Mélanger exercices d'analyse (identifier nature/fonction, figure de style) et exercices d'expression (réécriture, transformation, dictée courte).
- Pour la rédaction : sujet d'imagination ou de réflexion + critères d'évaluation.

### Histoire-géo
- Exercices de **repérage** (chronologie, carte).
- Exercices d'**analyse de document** (avec questions guidées).
- Exercices de **rédaction** (paragraphe argumenté ou développement construit).

### SVT et physique-chimie
- Exercices d'application de formule (avec données chiffrées).
- Exercices d'analyse d'expérience.
- Exercices d'analyse de schéma ou graphique.

### Anglais et allemand
- **Compréhension écrite** : court texte + questions en français ou en langue cible.
- **Grammaire ciblée** : transformation, complétion, choix multiple.
- **Expression écrite** : mini-rédaction avec critères de longueur et de contenu.
- **Phonétique** : si possible, indiquer la prononciation.

### Technologie
- Analyse d'objet technique.
- Lecture/correction d'un programme Scratch (texte décrivant les blocs).
- Schémas à compléter.

## Exemple complet (maths 4e, Pythagore)

```markdown
# Exercices : Théorème de Pythagore — 4e
**Notions** : application directe + réciproque + situation concrète
**Durée** : ~25 min
**Difficulté** : ★ → ★★ → ★★★

---

## Exercice 1 ★ — Application directe

ABC est un triangle rectangle en A. On donne AB = 6 cm et AC = 8 cm.
Calculer la longueur BC.

## Exercice 2 ★★ — Reconnaissance

DEF est un triangle tel que DE = 5 cm, EF = 12 cm et DF = 13 cm.
Le triangle DEF est-il rectangle ? Si oui, en quel sommet ? Justifier.

## Exercice 3 ★★★ — Situation concrète

Une échelle de 5 m est appuyée contre un mur. Le pied de l'échelle est posé à 1,5 m du mur. À quelle hauteur l'échelle touche-t-elle le mur ? Donner une valeur arrondie au centimètre.

---

# Corrigés

## Exercice 1

Le triangle ABC est rectangle en A, donc AB et AC sont les côtés de l'angle droit, et BC est l'hypoténuse.

D'après le théorème de Pythagore :
$$BC^2 = AB^2 + AC^2$$
$$BC^2 = 6^2 + 8^2 = 36 + 64 = 100$$
$$BC = \sqrt{100} = 10 \text{ cm}$$

**Conclusion** : Dans le triangle ABC rectangle en A, BC mesure 10 cm.

## Exercice 2

On cherche le côté le plus long : c'est DF (13 cm). Si le triangle est rectangle, son angle droit est nécessairement opposé à l'hypoténuse, donc à DF — c'est-à-dire en E.

**Calcul de la somme des carrés des deux autres côtés** :
$$DE^2 + EF^2 = 5^2 + 12^2 = 25 + 144 = 169$$

**Calcul du carré de l'hypoténuse présumée** :
$$DF^2 = 13^2 = 169$$

On a $DE^2 + EF^2 = DF^2$. D'après la **réciproque du théorème de Pythagore**, le triangle DEF est rectangle en E.

**Remarque** : (5, 12, 13) est un triplet pythagoricien classique — utile à reconnaître.

## Exercice 3

On modélise par un triangle rectangle, dont l'hypoténuse est l'échelle (5 m), un côté est la distance au mur (1,5 m) et l'autre côté est la hauteur cherchée $h$.

D'après le théorème de Pythagore :
$$5^2 = 1{,}5^2 + h^2$$
$$25 = 2{,}25 + h^2$$
$$h^2 = 25 - 2{,}25 = 22{,}75$$
$$h = \sqrt{22{,}75} \approx 4{,}77 \text{ m}$$

**Conclusion** : L'échelle touche le mur à environ 4,77 m de hauteur, soit 477 cm.

**Remarque** : ne pas oublier la conversion en cm si la question l'exigeait, et arrondir à l'unité demandée.
```

## Nombre d'exercices

- **Demande courte** (« quelques exercices ») : 3 exercices.
- **Demande longue** (« une fiche complète ») : 5-7 exercices.
- **Préparation contrôle / DNB** : peut aller jusqu'à 10 exercices, ou un sujet-type complet.

## Format / livraison

- Si la demande est courte, intègre les exercices dans la réponse.
- Si c'est une **fiche complète** (5+ exercices), propose de créer un **fichier `.md`** dans le dossier de travail que l'utilisateur pourra imprimer ou conserver. Demande son accord avant.

## Si l'élève veut aussi le corrigé après avoir essayé

Si l'élève dit « j'ai fait, vérifie » ou « j'ai bloqué sur le 2 » :
- Lis ce qu'il a fait.
- Pointe ce qui est bien.
- Sur les erreurs : **ne donne pas la solution directement** — bascule vers le mode aide aux devoirs (cf. `aide-devoirs.md`) sur l'exercice problématique.
