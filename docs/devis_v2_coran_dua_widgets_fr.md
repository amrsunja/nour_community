# DEVIS. Nour V2 : Coran, Mur des Dua, streak et widgets

**Prestataire :** Amir, Développeur Senior (Flutter / Supabase)
**Client :** Kevin Mesana, Nour App
**Date :** octobre 2026 (remplace les versions précédentes)
**Références :** Nour Specs V2 Final, document « Nour V2. La pensée et le concept », maquettes Figma « Nour community », échanges avec le client d'octobre 2026
**Devis lié :** Nour V2 : Premium, Family Pack et onboarding (devis séparé)

---

## 1. Contexte

Ce devis couvre le lecteur Coran, le Mur des Dua, les rappels de streak, les widgets d'écran d'accueil, les nouvelles polices, la finition de tous les écrans de la V2 et la mise en ligne de la V2 sur les stores. Le premier devis couvre les abonnements, le paywall, le Quiz Expert, le Pack Family et l'onboarding.

Après nos échanges, le périmètre a été précisé :

- Le Mur des Dua fonctionne sans modération préalable : la dua est publiée tout de suite et ne passe en vérification qu'après deux signalements.
- Le lecteur Coran est étendu : lecteur plein écran, mini-lecteur, lancement depuis la liste des sourates et des versets.
- Il y a maintenant 16 widgets (24 états au total) au lieu de 10.
- Nouvelles tâches : rappels de streak, nouvelles polices, mise en ligne sur les stores avec fiches en 11 langues et nouvelles captures d'écran.

Plusieurs éléments de ce devis s'appuient sur le socle Premium du premier devis : la publication sur le Mur des Dua, les récitateurs Premium et les widgets Premium.

L'infrastructure de notifications push de la partie 1 (Mosquées) est réutilisée pour les notifications Ameen et les rappels de streak sans coût supplémentaire.

---

## 2. Détail des fonctionnalités

### 2.1. Coran (offert)

Cette partie est offerte. L'écoute du Coran reste gratuite pour tous les utilisateurs de l'application.

**Lecteur plein écran**
- Changer de sourate en glissant, changer de récitateur, pause, avance et retour dans l'audio, volume.
- Les sourates s'enchaînent sans arrêt, l'application se souvient de l'endroit où l'utilisateur s'est arrêté.

**Mini-lecteur**
- Quand l'utilisateur quitte le lecteur plein écran, un mini-lecteur apparaît en bas, au-dessus de la barre de navigation. Il reste visible sur tous les onglets et ne cache jamais le texte.
- Un appui sur le mini-lecteur ouvre le lecteur plein écran.
- Un glissement vers le bas arrête l'audio et ferme le mini-lecteur.

**Lecture en arrière-plan**
- Le Coran continue de jouer quand l'application est en arrière-plan ou que l'écran est verrouillé.
- Contrôles sur l'écran verrouillé et dans la notification aux couleurs de Nour (visuel, nom de la sourate, récitateur).
- Bon comportement pendant un appel, avec une autre application audio et avec des écouteurs Bluetooth.

**Lancer le lecteur**
- Directement depuis la liste des sourates et depuis la page de la liste des versets (à partir du verset choisi).

**Récitateurs**
- Ajout de 5 à 7 nouveaux récitateurs au catalogue : nom, pays, style de récitation, écoute d'un extrait avant de choisir.
- Au total, 10 récitateurs sont réservés au Premium : badge Premium et paywall des récitateurs.

Aujourd'hui, le lecteur ne sait lire qu'un seul fichier et s'arrête à la fin de la sourate. Cette partie est donc en grande partie réécrite.

### 2.2. Mur des Dua

**Publication (Premium uniquement)**
- Seuls les utilisateurs Premium peuvent publier une dua. Un utilisateur gratuit voit le mur et peut dire Ameen. S'il essaie d'écrire une dua, il voit le paywall.
- Une dua par jour, remise à zéro à minuit heure locale, vérifiée côté serveur.
- La dua peut être publiée de façon anonyme ou avec son profil (prénom et photo).
- Section « Mes duas » : historique, nombre d'Ameen, modification et suppression.

**Fil et ordre d'affichage**
- L'utilisateur ne voit que les duas dans ses langues.
- Les duas qu'il n'a pas encore vues passent en premier, puis celles qu'il a déjà vues.
- Le serveur garde en mémoire ce que l'utilisateur a déjà vu, pour que l'ordre reste juste à chaque ouverture.
- Pagination optimisée (curseur et index en base) pour que le fil s'ouvre vite, même avec beaucoup de duas.
- Écrans selon la maquette : une dua par écran, glissement vers la suivante, mur vide, fin du fil, mode hors connexion.

**Ameen**
- Un seul Ameen par utilisateur et par dua, garanti par la base de données.
- L'auteur (Premium) reçoit une notification à chaque Ameen. Ces notifications peuvent être désactivées.

**Signalements et vérification**
- Tout utilisateur peut signaler une dua.
- Au deuxième signalement sur une même dua, elle passe automatiquement « en vérification » et disparaît du mur tout de suite.
- Le panneau d'administration affiche la liste des duas signalées : texte, auteur, nombre et motifs des signalements. L'administrateur remet la dua sur le mur ou la supprime. Chaque décision est enregistrée.

### 2.3. Streak et rappels

- Amélioration du système de streak : si l'utilisateur n'a encore rien fait aujourd'hui et que son streak est sur le point de s'interrompre, l'application le lui rappelle avec douceur.
- La vérification se fait côté serveur, selon l'heure locale de chaque utilisateur. Le rappel arrive le soir, quand il reste encore du temps pour garder son streak.
- L'utilisateur peut désactiver ces rappels dans les réglages.
- Textes des rappels en 11 langues, sans pression ni culpabilisation, comme le demande le document concept.

### 2.4. Widgets iOS et Android

Développement natif : Swift et WidgetKit pour iOS, Kotlin et Glance pour Android. Les widgets ne peuvent pas être faits en Flutter.

- 16 widgets selon les maquettes Figma, développés sur les deux plateformes, soit 32 widgets au total : heure de prière, ayah du jour, tasbih du jour, streak, en plusieurs tailles.
- Chaque widget a ses propres états, 24 au total (par exemple les cinq prières avec chacune son visuel, un streak à zéro, pas de données, pas de Premium).
- Widgets interactifs : compteur de tasbih au toucher et lecture de l'audio de l'ayah directement depuis le widget (sur iOS à partir de la version 17, sur les versions plus anciennes l'appui ouvre l'application).
- Les heures de prière sont calculées à l'avance, elles sont donc toujours exactes sur le widget, même sans connexion. Le compte à rebours avant la prière se met à jour tout seul.
- Lien entre l'application et les widgets : données partagées, vérification du Premium (si l'abonnement expire, le widget propose de le renouveler), les dhikr faits depuis le widget comptent dans l'ajr.
- Écran de réglage des widgets dans l'application : aperçu, choix de la taille, instructions pour les ajouter.

### 2.5. Design system et polices

- Le texte arabe des cartes passe à la police A Thuluth Regular.
- Le texte des versets du Coran passe à la police Amiri Quran.
- Les polices sont ajoutées au design system comme styles dédiés, puis tous les écrans sont mis à jour. Vérification des voyelles, des interlignes et de l'affichage de droite à gauche.

### 2.6. Finition de tous les écrans

- Pour chaque nouvel écran de la V2 (ce devis et le premier) : état de chargement, état vide, mode hors connexion, erreur, affichage gratuit et Premium.
- Vérification en arabe (de droite à gauche) et dans les langues aux mots longs (allemand, indonésien).
- Traduction des nouveaux textes dans les 11 langues et intégration. La relecture par des locuteurs natifs reste à votre charge.

### 2.7. Mise en ligne sur les stores

**Publication**
- Préparation des versions de production iOS et Android, numéros de version, signature.
- Envoi sur l'App Store et Google Play, suivi de la validation, réponses aux questions ou aux refus éventuels d'Apple et de Google jusqu'à la publication.
- Mise à jour des déclarations obligatoires : App Privacy (Apple) et Sécurité des données (Google), en tenant compte des abonnements et du Pack Family.

**Fiches des stores en 11 langues**
- Mise à jour du titre, du sous-titre, de la description, des mots-clés et du texte « Nouveautés » dans les 11 langues.
- Noms et descriptions des abonnements (Premium et Family) traduits dans les 11 langues, tels qu'ils apparaissent dans les stores.

**Nouvelles captures d'écran**
- Nouvelles captures d'écran qui montrent les fonctionnalités de la V2 (lecteur Coran, Mur des Dua, Pack Family, widgets, Premium), réalisées à partir de la page ASO du Figma.
- Déclinées dans les 11 langues et aux formats demandés par l'App Store et Google Play.

---

## 3. Prix

Prix forfaitaire pour l'ensemble des travaux décrits dans la section 2.

| Fonctionnalité | Montant |
|---|---|
| 2.2. Mur des Dua (publication, ordre du fil, pagination, Ameen, signalements, panneau d'administration) | 1 200 € |
| 2.3. Rappels de streak | 250 € |
| 2.4. Widgets iOS et Android (16 widgets × 2 plateformes = 32 widgets, 24 états) | 1 500 € |
| 2.5. Polices A Thuluth et Amiri Quran dans le design system | 150 € |
| 2.6. États des écrans, vérification de droite à gauche, traductions en 11 langues | 300 € |
| 2.7. Mise en ligne sur les stores, fiches en 11 langues, nouvelles captures d'écran | 400 € |
| **TOTAL** | **3 800 €** |
| 2.1. Coran (lecteur plein écran, mini-lecteur, arrière-plan, lancement depuis les listes, nouveaux récitateurs) | ~~1 000 €~~ **offert** |

**En option (non inclus dans le total)**

| Fonctionnalité | Montant |
|---|---|
| Téléchargement du Coran pour l'écouter sans connexion (par sourate, juz ou récitateur) | 400 € |
| CarPlay et Android Auto | 350 € |

---

## 4. Délais et paiement

**Délai :** environ 3 semaines après la signature, hors délais de validation Apple et Google et hors attente des maquettes manquantes.

**Paiement :**
- 30 % à la signature : 1 140 €
- 50 % à la livraison de la version de test (TestFlight et test interne Google Play) : 1 900 €
- 20 % à la mise en production : 760 €

---

## 5. Points importants

**Lien avec le premier devis.** La publication sur le Mur des Dua, les récitateurs Premium et les widgets Premium ont besoin du socle d'abonnements du premier devis pour fonctionner.

**Modération du Mur des Dua.** Les duas sont publiées tout de suite et ne sont vérifiées qu'après deux signalements. La liste des signalements dans le panneau d'administration doit être consultée régulièrement, sinon les duas signalées restent longtemps en attente.

**Police A Thuluth.** Amiri Quran est gratuite (licence OFL). Pour A Thuluth Regular, c'est à vous de vérifier la licence pour un usage dans une application mobile, et de l'acheter si besoin.

**Récitateurs.** Les nouveaux récitateurs viennent des mêmes sources ouvertes qu'aujourd'hui. Si un récitateur souhaité n'y figure pas, l'hébergement des fichiers et les droits sur les enregistrements restent à votre charge.

**Widgets sur iOS.** C'est iOS qui décide à quelle fréquence le widget se met à jour, pas l'application. Les heures de prière restent toujours exactes parce qu'elles sont calculées à l'avance. Les widgets interactifs fonctionnent à partir d'iOS 17.

**Validation des stores.** Le délai de validation dépend d'Apple et de Google, généralement de 1 à 3 jours. En cas de refus, je corrige et je renvoie la version sans coût supplémentaire, tant que le refus concerne le travail de ce devis.

**Ce dont j'ai besoin de votre part :** les maquettes manquantes (lecteur plein écran), les accès App Store Connect et Google Play Console, et la relecture des traductions (application et fiches des stores).

---

*Devis valable 30 jours. Les montants s'entendent hors taxes.*
