# DEVIS. Nour V2 : Quiz Histoire

**Prestataire :** Amir, Développeur Senior (Flutter / Supabase)
**Client :** Kevin Mesana, Nour App
**Date :** octobre 2026
**Références :** maquettes Figma « Nour community » (Quiz histoire), échanges avec le client d'octobre 2026
**Devis liés :** Nour V2 : Premium, Family Pack et onboarding, et Nour V2 : Coran, Mur des Dua, streak et widgets

---

## 1. Contexte

Le Quiz Histoire est un nouveau mode de jeu sous forme de parcours, inspiré de Duolingo. L'utilisateur avance sur une grande carte illustrée, niveau après niveau, et découvre l'histoire de l'islam en répondant à des questions.

Le contenu est organisé en **univers**. Pour l'instant, il n'y en a qu'un : **l'histoire des prophètes**, d'Adam à Muhammad ﷺ. L'application est pensée pour que d'autres univers puissent être ajoutés plus tard sans tout refaire.

Ce devis réutilise le socle d'abonnements et de paiement du premier devis (Premium, Family Pack et onboarding) pour l'accès Premium et l'achat d'énergie.

---

## 2. Détail des fonctionnalités

### 2.1. Structure du contenu et progression

**Organisation**
- Univers, puis chapitres, puis niveaux, puis questions.
- Un chapitre par prophète, de 9 niveaux chacun.
- Chaque niveau contient de 8 à 10 questions.
- L'ajout d'un nouvel univers ou d'un nouveau chapitre se fait par import de données, sans nouveau développement.

**Progression**
- Un niveau est validé quand l'utilisateur atteint un certain nombre d'ajr dans ce niveau. Ce score est affiché en étoiles selon la qualité de ses réponses.
- Le niveau suivant se débloque dès que le précédent est validé.
- Si l'utilisateur quitte un niveau en cours, il le reprend là où il s'est arrêté (par exemple « Question 4/10 » et « Continuer »).
- La progression, les étoiles et l'ajr gagné sont enregistrés côté serveur. L'ajr du Quiz Histoire compte dans l'ajr global de l'utilisateur (streak, page famille, etc.).

**Import du contenu**
- Script d'import des chapitres, niveaux et questions depuis un tableur, dans le même format multilingue que les quiz actuels.
- Ce devis livre l'outil d'import, pas le contenu. Le remplissage de la base avec les questions et le contenu des chapitres n'est pas inclus (voir section 5).

### 2.2. Carte du parcours

- Grande carte illustrée à faire défiler, avec le chemin et les niveaux sous forme d'étapes, selon la maquette.
- En-tête avec l'ajr total, l'énergie et le streak de la semaine.
- Bandeau du chapitre en cours (par exemple « Chapitre 01 : Les origines, Adam et Hawwa »).
- Fiche d'un niveau au toucher : nom du niveau, avancement des questions, coût en énergie, bouton « Commencer » ou « Continuer » avec l'ajr à gagner.
- États de chaque étape : terminée (avec ses étoiles), en cours, disponible, verrouillée.
- La carte s'ouvre automatiquement à l'endroit où l'utilisateur en est.

### 2.3. Écran de jeu

- Question avec texte arabe et translittération, et bouton pour écouter la prononciation (par exemple « alhamdulillāh »).
- Choix des réponses, bouton « Valider », retour immédiat bonne ou mauvaise réponse.
- Barre de progression des questions et énergie restante en haut de l'écran.
- Écran de fin de niveau : nombre de bonnes réponses, étoiles obtenues, ajr gagné, passage au niveau suivant.

### 2.4. Accès gratuit et Premium

- Les **3 premiers jeux** sont ouverts à tous, Premium ou non.
- Pour un utilisateur gratuit, les **3 niveaux suivants** sont visibles mais en gris. Au toucher, il voit le paywall Premium.
- Un utilisateur Premium continue de jouer sans limite et découvre la suite de la carte.
- Le reste de la carte est caché sous des nuages qui se dissipent au fur et à mesure de la progression.

### 2.5. Système d'énergie

- Chaque partie coûte 1 énergie.
- L'utilisateur a au maximum **3 énergies**.
- Une énergie perdue se recharge en **2 heures**, jusqu'à revenir au maximum de 3.
- Le compte et la recharge sont gérés côté serveur. Changer l'heure du téléphone ne permet pas de tricher.
- Affichage du temps restant avant la prochaine énergie.
- Quand l'énergie est à zéro, un écran propose d'attendre la recharge ou d'acheter de l'énergie.

### 2.6. Achat d'énergie

- Packs d'énergie vendus en achats intégrés (produits consommables sur l'App Store et Google Play).
- Réutilisation de la logique de paiement RevenueCat du premier devis : configuration des produits, achat, crédit de l'énergie côté serveur après validation de l'achat.
- Écran d'achat d'énergie dans le même style que les paywalls.

### 2.7. Animations (offertes)

Cette partie est offerte.

- **Première ouverture** : la caméra part du bas de la carte et remonte jusqu'en haut pour montrer que l'univers est grand et qu'il y a beaucoup de contenu, puis revient au premier niveau.
- **Nuages** : après les trois premiers jeux, le reste de la carte se couvre de nuages avec une belle animation. Ils s'écartent quand un nouveau niveau se débloque.
- Déblocage d'un niveau, apparition des étoiles, gain d'ajr, recharge d'énergie, célébration de fin de chapitre.
- Transitions entre la carte, la fiche du niveau et l'écran de jeu.

---

## 3. Prix

Prix forfaitaire pour l'ensemble des travaux décrits dans la section 2.

| Fonctionnalité | Montant |
|---|---|
| 2.1. Structure du contenu (univers, chapitres, niveaux), progression, étoiles, reprise, import | 500 € |
| 2.2. Carte du parcours, fiche de niveau, états des étapes | 700 € |
| 2.3. Écran de jeu, prononciation audio, écran de fin de niveau | 500 € |
| 2.4. Accès gratuit et Premium (3 jeux libres, 3 niveaux grisés avec paywall) | 150 € |
| 2.5. Système d'énergie (3 max, recharge toutes les 2 heures, côté serveur) | 400 € |
| 2.6. Achat d'énergie (achats intégrés via RevenueCat) | 250 € |
| **TOTAL** | **2 500 €** |
| 2.7. Animations (ouverture de la carte, nuages, déblocages, célébrations) | ~~600 €~~ **offert** |
| Remplissage de la base : questions et contenu des chapitres | **non inclus** |

---

## 4. Délais et paiement

**Délai :** environ 2 semaines, à la suite du premier devis (le socle d'abonnements et de paiement doit être en place). Hors délais de validation Apple et Google et hors attente des maquettes manquantes.

**Paiement :**
- 30 % à la signature : 750 €
- 50 % à la livraison de la version de test (TestFlight et test interne Google Play) : 1 250 €
- 20 % à la mise en production : 500 €

---

## 5. Points importants

**Remplissage de la base non inclus.** Ce devis ne comprend pas le remplissage de la base de données avec les questions et le contenu du Quiz Histoire. Cela concerne :
- la rédaction des questions et des réponses pour chaque niveau de chaque chapitre ;
- les textes des chapitres et des niveaux (titres, descriptions, explications) ;
- les traductions de ce contenu dans les différentes langues ;
- la vérification des sources et la validation religieuse ;
- la saisie de tout ce contenu dans le tableur d'import.

C'est un travail éditorial et religieux à part, à votre charge. De mon côté, je fournis le format du tableur et l'outil d'import : une fois le contenu prêt et validé, il est ajouté à l'application en quelques minutes. Pour les tests, j'utilise quelques questions d'exemple.

**Illustrations.** Les illustrations de la carte (paysages, chemin, éléments de décor) et les visuels des futurs chapitres sont fournis par le designer.

**Énergie et Premium.** Dans ce devis, l'énergie s'applique à tous les utilisateurs, Premium compris, et l'énergie supplémentaire s'achète à part. Si vous préférez une énergie illimitée pour les Premium, c'est un simple réglage, sans coût supplémentaire, à décider avant le développement.

**Prix des packs d'énergie.** Le contenu des packs (nombre d'énergies) et leurs prix sont à définir par vous. Apple et Google prélèvent leur commission sur ces achats comme sur les abonnements.

**Ce dont j'ai besoin de votre part :** les maquettes manquantes (fin de niveau, énergie à zéro, achat d'énergie, carte complète du premier chapitre), le contenu des premiers chapitres et les fichiers audio de prononciation s'ils ne sont pas générés automatiquement.

---

*Devis valable 30 jours. Les montants s'entendent hors taxes.*
