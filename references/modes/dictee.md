# Mode dictée (français)

Trois sources de dictée, à choisir selon le besoin :

| Besoin | Source | Voix |
|---|---|---|
| Préparer le brevet en conditions réelles (annales DNB) | **reviser-brevet.fr** (12 dictées MP3 directes) | Humaine, enregistrement officiel |
| Travailler un thème ou un niveau précis (6e→3e, par difficulté) | **dictaly.com** (~1100 dictées) ou **ladictee.fr** (~302 dictées par niveau) | Humaine, lecture en ligne |
| Dicter un texte sur mesure (poème à mémoriser, extrait du cours, contrôle ciblé sur une règle) | **`dictee-prof.sh`** (TTS local) | Synthétique (OpenAI ou `say`), workflow brevet reproduit |

Les deux premières privilégient la qualité de diction humaine ; la troisième offre la flexibilité (n'importe quel texte) avec un workflow pédagogique calibré sur les annales du brevet.

## Stratégie en 3 temps

1. **Choisir une dictée** adaptée au niveau / au thème / à la difficulté de l'élève (voir tableaux ci-dessous).
2. **Lancer l'audio** :
   - Si MP3 en accès libre (reviser-brevet.fr) : téléchargement direct + lecture locale.
     ```bash
     curl -sLo /tmp/dictee.mp3 "<URL_MP3>" && file /tmp/dictee.mp3 | grep -q "Audio" && afplay /tmp/dictee.mp3
     ```
     Le `file | grep` vérifie qu'on a bien reçu un MP3 et pas une page HTML de redirection (cf. dictaly qui redirige vers `/login` sans compte).
   - Sinon (compte requis, ou téléchargement non confirmé) : ouvrir la page de la dictée dans le navigateur, l'élève écoute en streaming.
     ```bash
     open "<URL_PAGE>"   # macOS
     ```
3. **Corriger** : l'élève écrit sur papier, photographie sa copie et la colle dans la conversation. Le prof compare à la correction (HTML de la page pour reviser-brevet, PDF téléchargé ou page web pour les autres) et explique chaque erreur.

## Tableau brevet (3e) — reviser-brevet.fr

12 dictées des annales du brevet (DNB), MP3 en téléchargement direct vérifié. Texte + corrigé + difficultés majeures sur la page HTML.

| Auteur | Œuvre | Année | URL MP3 | URL page |
|---|---|---|---|---|
| Flaubert | Trois contes | 2003 | https://www.reviser-brevet.fr/wp-content/uploads/2016/12/DicteeDNB2003sud.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-flaubert/ |
| Maupassant | Bel-ami (le duel) | 2003 | https://www.reviser-brevet.fr/wp-content/uploads/2016/12/DicteeDNB2003est.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-maupassant/ |
| Marcel Pagnol | Le temps des secrets | 2001 | https://www.reviser-brevet.fr/wp-content/uploads/2017/02/Dict_e-DNB-2001-Pagnol-2.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-marcel-pagnol/ |
| Colette | Le Blé en herbe | 2002 | https://www.reviser-brevet.fr/wp-content/uploads/2017/02/Dict_e-DNB-2002-Asie-Colette-2.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-colette/ |
| Salavina | Trente ans de Saint-Pierre | 2004 | https://www.reviser-brevet.fr/wp-content/uploads/2017/02/Dict_e-DNB-2002-Guadeloupe-Salavina-2.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-salavina/ |
| J. Lacarrière | (essai sur le livre) | 2004 | https://www.reviser-brevet.fr/wp-content/uploads/2016/12/Dictee-DNB-2004-ouest.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-lacarriere/ |
| J.M.G. Le Clézio | Les bergers | 2004 | https://www.reviser-brevet.fr/wp-content/uploads/2016/12/Dictee-DNB-2004-T.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-le-clezio/ |
| George Sand | Histoire de ma vie | 2004 | https://www.reviser-brevet.fr/wp-content/uploads/2016/12/Dictee-DNB-2005-ouest.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-george-sand/ |
| Jean-Louis Étienne | Le marcheur du pôle | 2005 | https://www.reviser-brevet.fr/wp-content/uploads/2017/01/Dict_e-DNB-2005-est-2.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-jl-etienne/ |
| J. Tournier | La Maison déserte | 2005 | https://www.reviser-brevet.fr/wp-content/uploads/2017/01/Dictee-DNB-2005-nord.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-tournier/ |
| Marcel Aymé | La Vouivre | 2006 | https://www.reviser-brevet.fr/wp-content/uploads/2016/12/DicteeDNB2006T.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-marcel-ayme/ |
| Baudelaire | Le port (Le spleen de Paris) | 2006 | https://www.reviser-brevet.fr/wp-content/uploads/2017/01/DicteeDNB2006.mp3 | https://www.reviser-brevet.fr/francais/methodologie/preparer-la-dictee-du-brevet/dictees-audio/texte-de-baudelaire/ |

## Tous niveaux par thème — dictaly.com (compte requis pour téléchargement)

~1100 dictées triables par **niveau** (CP→lycée), **difficulté** (Facile / Intermédiaire / Difficile / Extrême), **catégorie** (Littérature, Histoire, Nature, Politique, Nourriture, etc.) et **nombre de mots**.

⚠️ **Le téléchargement direct du MP3 et du PDF nécessite un compte gratuit** : un GET non authentifié sur l'URL MP3 redirige vers `/login`. Sans compte, il faut écouter la dictée en streaming sur la page web.

**Pattern URL** :
- Catalogue filtrable : https://www.dictaly.com/les-dictees
- Page d'une dictée (lecture en ligne, ouvrir avec `open <url>`) : `https://www.dictaly.com/dictees/<slug>`
- MP3 et PDF correction (compte requis) : `https://www.dictaly.com/dictees/<slug>.mp3` et `https://www.dictaly.com/dictees/<slug>.pdf/?download=true`

**Workflow sans compte** : fetch le catalogue avec les filtres, choisis une dictée correspondant au besoin, ouvre la page dans le navigateur (`open "https://www.dictaly.com/dictees/<slug>"`). L'élève écoute en ligne, écrit sur papier, photographie sa copie ; la correction reste accessible sur la page après inscription. Exemples de slugs réels :
- `midi-l-ombre-des-jours-anna-de-noailles` (Facile, 113 mots, Instant de vie)
- `chien-blanc-chien-blanc-romain-gary` (Intermédiaire, 122 mots)
- `la-montagne-histoire-d-une-montagne-histoire-d-un-ruisseau-elisee-reclus` (Difficile, 154 mots, Nature)

## Niveau collège générique — ladictee.fr

Catalogue par niveau scolaire (lecture en ligne, MP3 direct non garanti — privilégie ce site quand les autres ne couvrent pas le besoin).

| Niveau | Nombre | URL d'index |
|---|---|---|
| 6e | 59 | https://www.ladictee.fr/contenu/6eme/dictee_de_francais_classe_6eme_dictee.htm |
| 5e | 58 | (même domaine, page 5e — vérifier le slug à la volée) |
| 4e | 47 | https://www.ladictee.fr/contenu/4eme/dictee_de_francais_classe_4eme_dictee.htm |
| 3e | 126 | https://www.ladictee.fr/contenu/3eme/dictee_de_francais_classe_3eme_dictee.htm |
| Annales brevet | 12 | https://www.ladictee.fr/contenu/3eme/les_annales_du_brevet.htm |

## Dictée générée par TTS — `dictee-prof.sh`

Pour dicter un **texte sur mesure** non disponible dans les catalogues existants : poème du programme à mémoriser, extrait précis du cours, contrôle d'orthographe ciblé sur une règle (accord du participe passé, homophones, etc.), texte rédigé par le prof.

```bash
./scripts/dictee-prof.sh francais "Le chat dort sur le tapis. Il rêve de souris."
# Pour forcer une pause d'écriture fixe (en secondes) : 3e argument.
./scripts/dictee-prof.sh francais "..." 6
```

Le script reproduit le workflow officiel du brevet :
1. **Phase 1** — lecture intégrale au tempo normal (contextualisation, sans pause).
2. **Phase 2** — pour chaque phrase, dictée par **groupes de souffle** (~5-10 mots, ponctuation parlée à la fin : « virgule », « point »). Chaque chunk lu **deux fois** avec pause d'écriture entre les deux (~1.2 s/mot, 4-12 s). Après tous les chunks d'une phrase, **récap** en lecture continue.
3. **Phase 3** — relecture finale en chunks continus avec ponctuation parlée.

**Voix continue** : un seul appel par phase côté `say` (avec `[[slnc N]]`), audio concaténé via `ffmpeg` côté OpenAI (un MP3 par chunk unique + un par récap, silences réels insérés). Pas de re-génération de chunk → la voix ne « saute » pas entre les répétitions.

**Backend** : OpenAI TTS si `OPENAI_API_KEY` configurée (qualité quasi-humaine), sinon `say` macOS, sinon texte. Forçable via `PROF_BACKEND=say|openai|text`.

Qualité TTS toujours inférieure à une vraie voix humaine — pour la prépa brevet pure, préfère reviser-brevet.fr ; pour le travail thématique, préfère dictaly/ladictee. `dictee-prof.sh` est le bon choix dès qu'on a besoin d'un **contenu spécifique** que les catalogues n'offrent pas.

## Correction par photo

L'élève écrit sa dictée sur papier puis colle une photo dans la conversation. Le prof :
1. Lit la photo (vision native).
2. La compare au corrigé téléchargé (`/tmp/correction.pdf` pour dictaly, ou texte HTML pour reviser-brevet).
3. Liste les erreurs en les classant : orthographe lexicale / grammaticale, accord, conjugaison, ponctuation, accents.
4. Pour chaque erreur, donne la règle et un mini-exercice d'application.
