# Devis — Nour V2, Partie 2 (version révisée)

**Fonctionnalités Premium · Défis · Pack Family · Widgets · Lecteur Coran**

**Prestataire :** Amir — Développeur Senior (Flutter / Supabase)
**Client :** Kevin Mesana — Nour App
**Date :** octobre 2026 (remplace la version d'août 2026)
**Références :** Nour Specs V2 Final (juillet 2026) · **Nour V2 — La pensée et le concept (août 2026)** · maquettes Figma « Nour community » (pages Screens V2 : Paywall & upsell, Family plan, Dua wall, Widgets, Tools)
**Complément du devis Partie 1** (Module Mosquées & Infrastructure Push)

---

## 0. Ce qui change par rapport à la version d'août

La version d'août s'appuyait uniquement sur les Specs V2 de juillet. Le document « La pensée et le concept » et les maquettes Figma, arrivés depuis, modifient le périmètre sur plusieurs points. Lorsque les deux documents se contredisent, ce devis suit **le document concept** (le plus récent), sauf mention contraire.

| Sujet | Version d'août (specs) | Version révisée (concept + Figma) |
|---|---|---|
| Battle Quiz | Temps réel, réservé au Pack Family | **Défis asynchrones** (48 h), 3 cercles : famille, proches, inconnus |
| Quiz Expert | Leaderboard hebdo, badge « Savant de la semaine », rangs Savant / Maître | **Aucun classement public ni badge** ; relevé de progression par domaine ; un utilisateur gratuit peut goûter une question Expert |
| Pack Family | Dashboard, challenges, badges familiaux | **Espace famille** : chacun voit la progression et l'ajr des autres membres (sans classement), célébrations collectives, invitation qui fonctionne même sans l'app installée |
| Mineurs | « Pas de mode enfant ni contrôle parental » | Comptes mineurs protégés : pas d'appariement avec des inconnus sans réglage parental explicite |
| Mur des Dua | Publication directe, modération après signalement | **Modération avant publication** (statut « En revue »), modification / suppression de ses duas, lecture plein écran dua par dua, états vide / fin / hors-ligne |
| Paywall | 1 écran de conversion | Paywall principal + **essai gratuit 7 jours** + 2 paywalls contextuels (dua, récitateur) + écran de bienvenue Premium + bannière d'accueil |
| Widgets | 4 widgets × 2 tailles | **4 familles × 2 à 3 tailles (10 gabarits)**, dont un **tasbih interactif** et la **lecture audio de l'ayah depuis le widget** |
| Lecteur Coran | Non chiffré (supposé existant) | Mini-lecteur persistant, écoute continue entre sourates, arrière-plan, 10 nouveaux récitateurs — **offert** (voir section 9) |
| Qualité | — | États vide / chargement / hors-ligne / erreur / gratuit-Premium sur chaque écran, validation RTL et 11 langues |

---

## 1. Objet du devis

Cette seconde partie couvre l'ensemble des fonctionnalités V2 hors module Mosquées : le socle d'abonnements (RevenueCat) et les paywalls, le Mur des Dua, l'Assistant IA de progression, le Quiz Expert, les Défis, le Pack Family avec son espace famille, les widgets d'écran d'accueil iOS et Android, ainsi qu'une refonte du lecteur Coran, offerte.

L'application ne dispose aujourd'hui d'**aucune infrastructure d'abonnement** : le système Stripe existant ne gère que des dons. Ce socle est le préalable technique de toute la V2 et constitue le premier poste.

L'infrastructure push de la Partie 1 (Firebase Messaging + Supabase) est réutilisée telle quelle pour les notifications Ameen, défis et famille, sans coût supplémentaire.

---

## 2. Poste 1 — Socle Abonnements & Paywalls (RevenueCat)

Grille tarifaire (Figma + specs) : Premium mensuel 9,99 € · Premium annuel 59,99 € · Family annuel 69,99 € la 1ère année puis 89,99 € · Family mensuel 14,99 € (prévu dans les specs, absent du paywall Figma — à confirmer). Essai gratuit de 7 jours.

- **Achats intégrés iOS et Android via RevenueCat** : produits et groupes d'abonnement dans App Store Connect et Google Play Console, offerings RevenueCat, **essai gratuit de 7 jours** et prix de lancement Family (offres d'introduction, éligibilité gérée par les stores), restauration des achats, passage Solo → Family.
- **Source de vérité côté serveur** : les webhooks RevenueCat (achat, renouvellement, annulation, expiration, remboursement, problème de facturation) alimentent une table d'abonnements Supabase. Le statut Premium est calculé par une seule fonction serveur, utilisée partout. Ce n'est jamais le téléphone qui décide.
- **Écrans (Figma)** : paywall principal (3 offres, essai 7 jours, « Cancel anytime »), paywalls contextuels « Mur des Dua » et « Récitateur », écran de bienvenue Premium, bannière Premium sur l'accueil.
- **Verrouillage Premium transversal** : un même mécanisme pour toutes les fonctionnalités payantes. Un utilisateur qui repasse en gratuit perd l'accès proprement, sans être bloqué au milieu d'un parcours (principe 6 du concept).

---

## 3. Poste 2 — Mur des Dua

Conforme aux specs §1, ajusté aux maquettes.

- **Fil plein écran** : une dua par écran, défilement vertical lent (« dignité, pas un fil TikTok »), auteur (prénom/photo ou Anonyme), bouton Ameen avec compteur, signalement discret.
- **Publication** (Premium) : texte 280 caractères, choix prénom / anonyme, règle « 1 dua par jour, remise à zéro à minuit heure locale » appliquée côté serveur (en réutilisant la gestion du jour local déjà en base). Utilisateur gratuit → paywall contextuel.
- **Modération avant publication** : chaque dua passe par le statut « En revue » avant d'être visible. File de modération dans l'admin Nour existante (approuver / refuser), avec traçabilité. Une dua modifiée repasse en revue. Les contenus signalés sont masqués en attente de décision.
- **Mes duas** : historique, statut (En revue / publiée + nombre d'Ameen), modifier, supprimer.
- **Ameen** : un seul par utilisateur et par dua (contrainte en base), notification au posteur (Premium), réglage on/off.
- **États** : mur vide (« The wall is quiet »), fin du fil, hors-ligne (affichage du contenu en cache, synchronisation au retour du réseau).

---

## 4. Poste 3 — Assistant IA de progression

Conforme aux specs §2 et au concept §4.2 : **un miroir, pas un interlocuteur**. Pas de chat, pas de champ de saisie. L'IA ne parle que des données de l'utilisateur.

- **Agrégation des statistiques** : fonction serveur qui consolide streak, ajr, dhikr, quiz, duas et jours actifs à partir des compteurs déjà en place (`ajr_log`, `daily_activity`).
- **Génération du bilan** : au plus une requête IA par jour et par Premium, déclenchée à l'appui sur le bouton, puis mise en cache en base. Le prompt est strictement borné (constat, un conseil, un objectif, un encouragement) et le texte est généré dans la langue de l'utilisateur (11 langues).
- **Écran bilan** de type « lettre » (2 à 8 lignes), objectif du jour avec progression, actions directes (Commencer le dhikr / Lancer un quiz). Quatre états prévus : premier usage, journée vide, journée riche, retour après une absence (ton d'accueil, jamais de reproche).
- **Historique** des 30 derniers bilans, avec objectif atteint ou non (vérification automatique en fin de journée).

Le coût d'API du fournisseur d'IA est un coût d'exploitation à la charge du client, distinct de ce devis.

---

## 5. Poste 4 — Quiz Expert

Conforme aux specs §3, ajusté au concept §4.3. Les niveaux Débutant et Intermédiaire ne changent pas.

- **Modèle de données** : 5 catégories (Qur'an, Hadith, Seerah, Fiqh, Histoire islamique), 3 types de questions (QCM, Vrai/Faux, texte à compléter), explication détaillée et source pour chaque question.
- **Session** : choix de 5, 10 ou 15 questions, minuteur optionnel de 30 s. **L'écran d'explication suit chaque réponse : c'est l'écran clé.**
- **Découverte par un utilisateur gratuit** : il voit le niveau Expert, comprend ce qu'il contient, goûte une question, puis se voit proposer le Premium. Jamais un cadenas sans explication.
- **Relevé de progression par domaine** : précision par catégorie, thèmes maîtrisés et thèmes à travailler. Cet indicateur alimente aussi les titres des Défis (poste 5).
- **Pipeline d'import** des packs de questions depuis un tableur (même format trilingue FR/EN/AR que les quiz existants).
- *Retiré par rapport à la version d'août : leaderboard hebdomadaire, badge « Savant de la semaine », rangs Savant / Maître (exclus par le concept).*

La **rédaction des questions** n'est pas incluse (voir section 12).

---

## 6. Poste 5 — Défis (asynchrones)

Remplace le Battle Quiz temps réel. Conforme au concept §4.4.

- **Cycle de vie** : je lance un défi et je joue mes questions tout de suite ; l'adversaire a 48 h pour jouer. Les états sont gérés côté serveur : en attente, à jouer, terminé, expiré, forfait, avec un plafond de défis ouverts en même temps. Une tâche planifiée gère les expirations.
- **Carte du duel** (avant / pendant / après) et **comparaison question par question**. L'explication détaillée est débloquée pour les deux joueurs.
- **Cercles famille et proches** : défier un membre du Pack ou un proche invité par lien.
- **Cercle inconnus** : appariement par niveau (gagner fait affronter plus fort), « fantôme » d'une vraie partie précédente quand personne n'est disponible, clairement signalé comme tel. Aucun bot déguisé.
- **Valorisation** : titre descriptif par domaine (« Solide sur la Sîra »), calculé sur la précision et jamais sur le nombre de victoires (pas de farming possible) ; indicateur de fiabilité (« répond toujours à ses défis ») ; revanche lancée par le gagnant, qui choisit le thème.
- **Ce qui n'existe pas** : classement public, annuaire, recherche de joueurs, messages libres, emojis, objets à collectionner.
- **Protection des mineurs** : un compte mineur d'un Pack reste limité aux cercles famille et proches. L'ouverture aux inconnus passe par un réglage parental explicite.
- **Notifications** : défi reçu, à toi de jouer, résultat, défi bientôt expiré.

*Hypothèse retenue : lancer un défi est réservé aux Premium (Solo et Family) ; accepter un défi est ouvert à tous, ce qui sert de canal d'acquisition. À confirmer.*

---

## 7. Poste 6 — Pack Family

Conforme aux specs §6 et au concept §4.5. **Un espace familial, pas un abonnement à plusieurs.**

- **Groupe et droits partagés** : le gestionnaire du pack et jusqu'à 4 membres, sans jargon technique. Un utilisateur appartient à un seul groupe. Le Premium des membres est calculé côté serveur à partir de l'abonnement du gestionnaire : si un membre quitte le groupe, il repasse en gratuit ; si le gestionnaire résilie, tout le groupe perd le Premium. États prévus : places restantes, invitation en attente, membre qui quitte, pack plein.
- **Invitation en 10 secondes** (Figma : « Share invite link », « Karim invites you to join ») : lien universel valable 48 h. Si l'app n'est pas installée, le lien renvoie vers le store, puis l'invitation est retrouvée au premier lancement (lien différé ou code d'invitation de secours). L'invité arrive ensuite sur l'écran « Join the plan » puis sur l'onboarding (prénom, création de compte).
- **Espace famille « type Duolingo »** : chaque membre voit la progression des autres : ajr du jour et de la semaine, streak, activité du jour (dhikr, quiz, ayah, dua). Encouragements prédéfinis (pas de messagerie libre), célébrations collectives, **aucun classement entre membres**. Le journal personnel, les duas personnelles et le bilan IA restent strictement privés. Techniquement, on s'appuie sur `ajr_log` et `daily_activity` déjà en base, exposés au groupe par une fonction serveur dédiée et des règles d'accès (RLS).
- **Challenges collectifs** : objectifs prédéfinis (dhikr en famille, quiz, 1 dua par jour, Ramadan, lecture du Qur'an). La progression collective est alimentée automatiquement par l'activité de chacun, avec une notification à chaque jalon. Pas de badges ni de trophées (concept).
- **Tests multi-appareils** (iOS + Android en famille croisée).

---

## 8. Poste 7 — Widgets iOS & Android

Développement **natif** (Swift / WidgetKit et Kotlin / Glance), conforme aux maquettes Figma :

| Widget | Tailles | Particularités | Accès |
|---|---|---|---|
| Prochaine prière | S · M · L | 5 visuels (Fajr → Isha), compte à rebours ; L : liste du jour, date hégirienne, mosquée principale (module Mosquées) | Gratuit |
| Ayah du jour | M · L | Arabe + traduction ; L : **lecture audio depuis le widget** | Premium |
| Tasbih du jour | S · M · L | **Compteur interactif** (appui = +1), plusieurs dhikr, synchronisé avec l'ajr de l'app | Premium |
| Streak | S · M | Semaine en cours, état « Ralume ta flamme » à 0 | Premium |

- **iOS** : timeline pré-calculée pour les horaires (exacts même sans réseau), interactions via App Intents (iOS 17 et plus), partage de données par App Group.
- **Android** : Glance avec actions et rafraîchissement planifié.
- **Pont app ↔ widgets** : données partagées, verrouillage Premium (un widget Premium affiche une invitation si l'utilisateur repasse en gratuit), remontée des dhikr comptés depuis le widget vers l'ajr.
- **Écran de configuration** : aperçu, choix de la taille, instructions d'ajout pas à pas pour iOS et Android.

*Le widget « Compte à rebours Ramadan » des specs n'apparaît pas dans Figma. Il n'est pas chiffré ici (option : 1,5 j, voir section 10).*

---

## 9. Lot Coran — offert

L'écoute du Coran reste gratuite pour les utilisateurs (concept §4.1). Ce lot est **offert** par le prestataire.

- **Lecteur global et écoute continue** : file de lecture qui enchaîne les sourates sans interruption, sourate précédente / suivante, reprise à la dernière position. Aujourd'hui, le lecteur ne charge qu'une source à la fois et s'arrête en fin de sourate.
- **Mini-lecteur persistant** (Figma) : numéro et nom de la sourate, récitateur, précédent / pause / suivant, barre de progression. Il est visible sur tous les onglets, au-dessus de la barre de navigation, et ne couvre jamais le texte lu.
- **Lecture en arrière-plan et écran verrouillé** : contrôles sur l'écran verrouillé et dans la notification aux couleurs de Nour (visuel, titres), gestion des interruptions (appel, autre app audio), casque Bluetooth, mute / unmute.
- **10 nouveaux récitateurs** : intégration au catalogue, fiche (nom, nationalité, style), aperçu audio.
- **Verrouillage Premium des récitateurs** (badge, paywall récitateur) : voir le point d'attention en section 12.

---

## 10. Chiffrage

Taux journalier : 600 € HT.

| Poste | Jours | Montant |
|---|---|---|
| **1. Socle Abonnements & Paywalls** | | |
| RevenueCat : produits, offerings, essai 7 j, offre de lancement Family | 3 | 1 800 € |
| Webhooks, table d'abonnements, calcul des droits côté serveur | 3 | 1 800 € |
| Paywall principal + 2 contextuels + bienvenue + bannière, restauration, verrouillage transversal | 4,5 | 2 700 € |
| **Sous-total** | **10,5** | **6 300 €** |
| **2. Mur des Dua** | | |
| Base de données, sécurité, règle 1/jour, statuts de modération | 3 | 1 800 € |
| Fil plein écran, Ameen, états vide / fin / hors-ligne | 3 | 1 800 € |
| Publication, Mes duas (modifier / supprimer), confirmation | 2 | 1 200 € |
| Notifications Ameen + réglages | 1,5 | 900 € |
| Modération avant publication + signalements (admin existante) | 2 | 1 200 € |
| **Sous-total** | **11,5** | **6 900 €** |
| **3. Assistant IA de progression** | | |
| Agrégation des statistiques, stockage des bilans | 2 | 1 200 € |
| Génération IA : prompt borné, cache quotidien, 11 langues | 3 | 1 800 € |
| Écran bilan, 4 états, objectif du jour, actions directes | 2,5 | 1 500 € |
| Historique 30 bilans + suivi d'objectifs | 1,5 | 900 € |
| **Sous-total** | **9** | **5 400 €** |
| **4. Quiz Expert** | | |
| Modèle de données : catégories, types, explications, sources | 2 | 1 200 € |
| Sessions : 5/10/15, minuteur, 3 types, écran d'explication | 4 | 2 400 € |
| Découverte pour les gratuits (question d'essai → paywall) | 1 | 600 € |
| Relevé de progression par domaine | 2 | 1 200 € |
| Pipeline d'import des packs | 1 | 600 € |
| **Sous-total** | **10** | **6 000 €** |
| **5. Défis asynchrones** | | |
| Cycle de vie, expiration 48 h, forfait, plafond, tâche planifiée | 3 | 1 800 € |
| Carte du duel, comparaison question par question | 3 | 1 800 € |
| Cercles famille et proches | 1,5 | 900 € |
| Cercle inconnus : appariement par niveau, fantôme | 3 | 1 800 € |
| Titres par domaine, fiabilité, revanche | 2 | 1 200 € |
| Notifications de défi | 1 | 600 € |
| Protection mineurs + réglage parental | 1,5 | 900 € |
| **Sous-total** | **15** | **9 000 €** |
| **6. Pack Family** | | |
| Groupe, rôles, droits partagés, règles de sortie, états | 4 | 2 400 € |
| Invitation par lien (y compris sans app installée) + parcours « Join the plan » | 3 | 1 800 € |
| Produit Family dans RevenueCat, propagation des droits aux membres | 1,5 | 900 € |
| Espace famille : progression et ajr de chaque membre, encouragements | 3,5 | 2 100 € |
| Challenges collectifs, jalons, notifications | 3 | 1 800 € |
| Tests multi-appareils | 1 | 600 € |
| **Sous-total** | **16** | **9 600 €** |
| **7. Widgets iOS & Android** | | |
| iOS — WidgetKit : 10 gabarits, timeline, App Intents (tasbih, audio) | 6 | 3 600 € |
| Android — Glance : 10 gabarits, actions, rafraîchissement planifié | 5 | 3 000 € |
| Pont app ↔ widgets, verrouillage Premium, synchronisation de l'ajr | 2,5 | 1 500 € |
| Écran de configuration | 1 | 600 € |
| **Sous-total** | **14,5** | **8 700 €** |
| **8. Transverse** | | |
| États par écran (vide, chargement, hors-ligne, erreur, gratuit/Premium), recette RTL | 3 | 1 800 € |
| Localisation des nouvelles chaînes (11 langues : génération + intégration) | 1,5 | 900 € |
| **Sous-total** | **4,5** | **2 700 €** |
| **TOTAL Partie 2** | **91** | **54 600 €** |
| **9. Lot Coran** (lecteur continu, mini-lecteur, arrière-plan, 10 récitateurs, verrouillage) | *9* | *~~5 400 €~~* **Offert** |

Fourchette avec provision pour imprévus : **54 000 – 60 000 €**.

**Options (non incluses)**

| Option | Jours | Montant |
|---|---|---|
| Téléchargement hors-ligne (par sourate / juz / récitateur, gestion du stockage, indicateurs) | 4,5 | 2 700 € |
| CarPlay / Android Auto (contrôles et navigation dans le catalogue) | 4 | 2 400 € |
| Écran d'écoute plein écran « immersion » | 2 | 1 200 € |
| Widget Compte à rebours Ramadan (iOS + Android) | 1,5 | 900 € |
| Pré-filtrage IA des duas avant modération humaine | 1,5 | 900 € |
| *Variante réduite : Défis sans le cercle inconnus* | *−4,5* | *−2 700 €* |

**Récapitulatif V2 complète** (Parties 1 + 2) : 135,5 jours · **80 000 – 89 500 €** HT · lot Coran offert en plus.

---

## 11. Planning et lien avec Ramadan 2027

91 jours représentent **environ 18 à 19 semaines** à temps plein. Ramadan 2027 commence vers le **8 février 2027** (date à confirmer selon l'observation du croissant). Pour que l'essentiel soit en ligne avant, livraison en deux vagues :

**Vague 1 — avant Ramadan** (≈ 13 semaines, livraison visée mi-janvier 2027, ce qui laisse 3 semaines pour la validation Apple/Google et le marketing) :
1. Lot Coran *(offert)* + Socle Abonnements & Paywalls
2. Mur des Dua
3. Widgets
4. Pack Family + espace famille

**Vague 2 — pendant / après Ramadan** :
5. Quiz Expert
6. Assistant IA
7. Défis (s'appuient sur le relevé par domaine du Quiz Expert)

**Modalités de paiement** : 30 % à la commande, paiement par jalon à chaque livraison, solde de 20 % à la livraison finale.

---

## 12. Points d'attention

**Récitateurs Premium : contradiction à trancher.** Les specs et le Figma (paywall « Unlock your favorite reciters ») prévoient des récitateurs Premium. Le document concept dit au contraire : « L'écoute du Coran restera toujours gratuite… Aucun élément Premium ne se pose sur ces écrans. » Le verrouillage est prêt techniquement (inclus dans le lot offert), mais la décision vous revient avant la mise en production.

**Le socle d'abonnements est un prérequis absolu.** Les démarches côté client doivent démarrer dès la signature : contrats « Apps payantes » et informations fiscales et bancaires dans App Store Connect et Play Console, programme Small Business d'Apple (commission de 15 %), textes légaux des abonnements (CGV, mention du renouvellement automatique, conditions de l'essai gratuit).

**RevenueCat.** Gratuit jusqu'à 2 500 $ de revenus mensuels suivis, puis environ 1 % (grille publique actuelle). C'est un coût d'exploitation modeste au regard de ce qu'il évite : la validation des reçus Apple/Google faite maison.

**Modération du Mur des Dua.** Avec une modération avant publication, chaque dua attend une validation humaine. Il faut donc une personne disponible chaque jour, sinon le mur se fige. L'option de pré-filtrage IA réduit la file d'attente sans remplacer la décision humaine.

**Défis et mineurs.** Les specs excluaient tout mode enfant ; le concept introduit des comptes mineurs dans le Pack. Ce devis suit le concept. Il faudra définir comment un compte est déclaré mineur (déclaration du gestionnaire du pack, par exemple).

**Contenu du Quiz Expert non inclus.** La rédaction des questions des 5 catégories, avec sources vérifiées et validation religieuse, est une prestation éditoriale distincte.

**Coût d'exploitation de l'IA.** Au plus une requête par jour et par Premium, plafond appliqué côté serveur. Coût récurrent à la charge du client.

**Récitateurs : sources audio.** Les nouveaux récitateurs proviennent des sources ouvertes déjà utilisées par l'application. Si certains récitateurs souhaités n'y figurent pas, l'hébergement (CDN) et les droits d'utilisation des enregistrements sont à la charge du client.

**Widgets iOS.** Le rythme de rafraîchissement est décidé par iOS et non par l'application. La timeline pré-calculée garantit des horaires de prière exacts à l'affichage ; le compte à rebours s'actualise en continu sans dépendre du réseau. Le tasbih interactif et la lecture audio depuis le widget nécessitent iOS 17 ou plus ; sur une version antérieure, l'appui ouvre l'application.

**Dépendances.** Infrastructure push de la Partie 1 ; maquettes encore à recevoir pour l'Assistant IA, le Quiz Expert et les Défis (absentes du Figma à ce jour) ; traductions relues par des locuteurs natifs côté client.

---

*Devis valable 30 jours. Les montants s'entendent hors taxes.*
