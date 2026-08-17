# Devis — Nour V2, Partie 2

**Fonctionnalités Premium · Pack Family · Widgets**

**Prestataire :** Amir — Développeur Senior (Flutter / Supabase)
**Client :** Kevin Mesana — Nour App
**Date :** août 2026
**Références :** Nour Specs V2 Final (sections 1 à 6 et 8) · matrice Gratuit vs Premium
**Complément du devis Partie 1** (Module Mosquées & Infrastructure Push)

---

## 1. Objet du devis

Cette seconde partie couvre l'ensemble des fonctionnalités V2 hors module Mosquées : le socle d'abonnements et le paywall, le Mur des Dua, l'Assistant IA de progression, le Quiz Expert, les Récitateurs Premium, le Pack Family avec son Battle Quiz, et les widgets d'écran d'accueil iOS et Android.

Un point mérite d'être posé d'emblée : les spécifications décrivent des fonctionnalités Premium, mais l'application ne dispose aujourd'hui d'**aucune infrastructure d'abonnement**. Le système Stripe existant gère uniquement des dons ponctuels ; il n'y a ni achat intégré, ni gestion de droits Premium, ni écran de conversion. Ce socle est le préalable technique de toute la V2 — sans lui, aucune des fonctionnalités payantes ne peut être livrée ni facturée aux utilisateurs. Il constitue donc le premier poste de ce devis.

L'infrastructure de notifications push (Firebase Messaging + Supabase), chiffrée dans la Partie 1, est réutilisée ici telle quelle pour les notifications Ameen et les alertes familiales, sans coût supplémentaire.

---

## 2. Poste 1 — Socle Abonnements & Paywall

Le modèle tarifaire validé (Premium Solo 9,99 €/mois ou 59,99 €/an, Pack Family 14,99 €/mois ou 89,99 €/an) repose sur les achats intégrés Apple et Google — c'est ce qu'impliquent les commissions de 15 % mentionnées dans les spécifications.

### Ce qui sera mis en place

- **Achats intégrés iOS et Android** via RevenueCat : configuration des produits dans App Store Connect et Google Play Console, intégration du SDK, gestion des offres annuelles et de l'offre de lancement Family.
- **Source de vérité côté serveur** : les événements d'abonnement (achat, renouvellement, annulation, expiration, remboursement) sont reçus par webhook et enregistrés dans Supabase. Le statut Premium d'un utilisateur est calculé par une fonction serveur unique, interrogée partout dans l'application — jamais décidé par le client.
- **Écran de conversion (paywall)** : l'écran clé mentionné dans le Lot 1, présentant les offres Solo et Family, avec restauration d'achats et gestion des cas particuliers (changement d'appareil, passage Solo → Family).
- **Verrouillage Premium transversal** : chaque fonctionnalité payante vérifie les droits via le même mécanisme ; un utilisateur qui repasse en Gratuit perd l'accès proprement, avec redirection vers l'écran de conversion.

Ce poste conditionne tous les suivants et sera livré en premier.

---

## 3. Poste 2 — Mur des Dua

Conforme à la section 1 des spécifications.

- **Fil communautaire** : liste des duas en ordre antichronologique, défilement infini par pages de 20, carte affichant prénom ou « Anonyme », texte, heure, compteur et bouton Ameen, bouton de signalement.
- **Publication** : bouton flottant ; modal de saisie (280 caractères, choix prénom/anonyme) pour les Premium ; écran de conversion pour les utilisateurs gratuits ; message « Reviens demain » si la dua du jour a déjà été postée. La règle « 1 dua par jour, remise à zéro à minuit heure locale » est appliquée côté serveur, en réutilisant la gestion du jour local déjà présente dans la base.
- **Ameen** : un seul par utilisateur et par dua, garanti par contrainte en base ; notification push au posteur pour chaque Ameen reçu (Premium), avec écran d'activation/désactivation.
- **Historique** : liste de ses propres duas pour les Premium.
- **Signalement et modération** : tout contenu signalé est immédiatement masqué en attente de décision ; écran de modération intégré à l'admin Nour existante (approuver / supprimer), avec traçabilité des décisions.

---

## 4. Poste 3 — Assistant IA de progression

Conforme à la section 2 des spécifications, dans le périmètre strict défini : un conseil par jour, pas de chat libre, pas de questions religieuses ouvertes.

- **Agrégation des statistiques** : fonction serveur consolidant streak, dhikr et quiz de la semaine, duas postées et jours actifs — en s'appuyant sur les compteurs déjà en place dans l'application.
- **Génération du conseil** : une requête IA par jour et par utilisateur Premium, déclenchée à la première ouverture du jour et mise en cache en base (aucun appel superflu, coût maîtrisé conformément à l'estimation des spécifications). Le prompt est strictement borné : analyse des chiffres, un conseil, un objectif, un encouragement — rien d'autre. Le conseil est généré dans la langue de l'utilisateur (12 langues supportées).
- **Dashboard** : résumé des statistiques, conseil du jour en carte principale, objectif du jour avec barre de progression, boutons d'action directs (« Commencer le dhikr », « Lancer un quiz »).
- **Suivi d'objectif** : vérification automatique en fin de journée (l'objectif proposé est-il atteint ?), alimentant l'historique.
- **Historique** : les 30 derniers conseils avec indicateur objectif atteint / non atteint.

Le coût d'API du fournisseur d'IA (~300 €/mois pour 10 000 Premium actifs selon vos estimations) est un coût d'exploitation à la charge du client, distinct de ce devis.

---

## 5. Poste 4 — Quiz Expert

Conforme à la section 3. Le quiz existant (Débutant / Intermédiaire, quotidien) reste inchangé pour les utilisateurs gratuits.

- **Évolution du modèle de données** : ajout des 5 catégories Expert (Qur'an, Hadith, Seerah, Fiqh, Histoire islamique), des trois types de questions (QCM à 4 choix, Vrai/Faux, texte à compléter), et des champs explication détaillée + source (verset, hadith, référence) pour chaque question.
- **Sélection et session** : grille des catégories avec progression et nombre de questions disponibles ; choix de 5, 10 ou 15 questions ; minuteur optionnel de 30 secondes par question ; explication et source affichées après chaque réponse ; score final avec les rangs Débutant / Érudit / Savant / Maître.
- **Leaderboard hebdomadaire** : classement des Premium par score total, remis à zéro chaque semaine côté serveur, badge « Savant de la semaine » attribué automatiquement au premier.
- **Pipeline de contenu** : script d'import des packs de questions depuis fichiers tableur (même format trilingue FR/EN/AR que les quiz existants), pour que l'ajout du pack mensuel soit une opération de quelques minutes, sans développement.

La **rédaction des questions** (contenu initial des 5 catégories et packs mensuels) n'est pas incluse — voir section 10.

---

## 6. Poste 5 — Récitateurs Premium

Conforme à la section 4. L'application intègre déjà 9 récitateurs et un lecteur audio complet avec lecture en arrière-plan — ce poste est une extension, pas une construction.

- **Bibliothèque étendue** : passage à 10 récitateurs et plus, avec fiche par récitateur (nom, nationalité, style de récitation) et aperçu audio avant sélection.
- **Répartition Gratuit / Premium** : 3 récitateurs gratuits affichés en premier, les autres avec badge Premium ; tentative d'accès par un utilisateur gratuit → écran de conversion.
- **Personnalisation audio avancée** (Premium) : vitesse de lecture, répétition de versets, enchaînement continu. Le périmètre exact de « personnalisation complète » étant peu détaillé dans les spécifications, il sera précisé ensemble avant développement — le chiffrage ci-dessous couvre les trois options citées.

Si certains récitateurs supplémentaires ne sont pas disponibles dans les sources audio actuelles de l'application, l'hébergement de leurs fichiers (CDN, droits d'utilisation) sera à prévoir séparément — voir section 10.

---

## 7. Poste 6 — Pack Family

Conforme à la section 6. C'est le poste le plus conséquent du devis, pour une raison précise : le Battle Quiz en temps réel est une fonctionnalité multijoueur synchrone, une catégorie de développement sensiblement plus exigeante que le reste de l'application.

### F1. Groupes et abonnement partagé

- Création du groupe à l'achat du Pack Family par l'admin (produit dédié dans les stores, offre de lancement 69,99 € la première année incluse).
- **Invitations** : lien profond et QR code valables 48 heures ; vérification serveur de la limite de 5 membres et de la règle « un utilisateur ne peut appartenir qu'à un seul groupe ».
- **Droits partagés** : le statut Premium des membres est calculé dynamiquement à partir de l'abonnement de l'admin — si un membre quitte le groupe, il repasse immédiatement en Gratuit ; si l'admin annule, tous les membres perdent le Premium, sans aucune synchronisation manuelle ni cas de désynchronisation possible.
- Confidentialité : seuls les streaks et milestones sont visibles du groupe, les données personnelles restent privées.

### F2. Dashboard famille

Liste des membres (avatar, prénom, streak, dernière activité), challenge en cours avec progression collective, historique des battles et badges, bouton d'invitation.

### F3. Challenges familiaux

- Objectifs collectifs prédéfinis : 500 dhikr en famille, 30 quiz, 1 dua par jour, challenge Ramadan, lecture du Qur'an.
- La progression collective est alimentée automatiquement par l'activité individuelle existante (compteurs de dhikr, parties de quiz) — aucun geste supplémentaire demandé aux membres.
- Notification push à tous les membres à chaque milestone ; badges familiaux (« 7 jours ensemble », « Ramadan en famille », « Objectif atteint »).

### F4. Battle Quiz Family (temps réel)

- **Lobby** : l'admin lance une partie, les membres présents rejoignent en direct.
- **Modes** : 5 / 10 / 15 questions, difficulté Débutant / Intermédiaire / Expert.
- **Partie synchrone** : la question s'affiche au même moment sur tous les écrans ; le point revient à la première bonne réponse. L'arbitrage est entièrement côté serveur — c'est l'horloge du serveur qui départage, jamais celle des téléphones, ce qui rend la triche par manipulation d'horloge impossible.
- **Classement en temps réel** pendant la partie ; résultat final privé au groupe avec animation de victoire.
- **Robustesse** : reprise de partie après déconnexion, gestion du départ d'un joueur en cours de jeu, de l'admin quittant le lobby, des réponses simultanées en limite de temps. Ces cas limites représentent une part importante du travail et sont indispensables pour une expérience familiale fluide.
- Tests multi-appareils systématiques (iOS + Android en partie croisée).

---

## 8. Poste 7 — Widgets iOS & Android

Conforme à la section 8. Il s'agit de développement **natif** (Swift et Kotlin), en dehors de Flutter — les widgets d'écran d'accueil ne peuvent pas être réalisés autrement.

- **iOS — WidgetKit (SwiftUI)** : les 4 widgets (Heure de prière, Adhkar du jour, Streak, Compte à rebours Ramadan), tailles petite et moyenne, partage de données avec l'application via App Group.
- **Android — Glance** : les mêmes 4 widgets, avec rafraîchissement planifié.
- **Rafraîchissement des horaires de prière** : cible de 15 minutes. Sur Android, ce rythme est tenable ; sur iOS, le système attribue un budget de mises à jour que l'application ne contrôle pas totalement — les horaires de prière étant calculables à l'avance, le widget utilisera une timeline pré-générée, ce qui garantit l'exactitude de l'affichage même sans rafraîchissement réseau. Ce point est un comportement d'iOS, pas une limite de l'implémentation.
- **Gestion Premium** : les widgets Adhkar, Streak et Ramadan sont réservés aux Premium ; si l'utilisateur repasse en Gratuit, le widget affiche une invitation à se réabonner.
- **Écran de configuration** dans l'application : choix du widget, taille, aperçu, instructions d'ajout pas à pas pour iOS et Android.

---

## 9. Chiffrage

| Poste | Jours | Montant |
|---|---|---|
| **1. Socle Abonnements & Paywall** | | |
| Achats intégrés iOS/Android (RevenueCat), produits, offres | 3 | 1 800 € |
| Webhooks, table d'abonnements, calcul des droits côté serveur | 3 | 1 800 € |
| Paywall, restauration, verrouillage Premium transversal | 4 | 2 400 € |
| **Sous-total** | **10** | **6 000 €** |
| **2. Mur des Dua** | | |
| Base de données, sécurité, règle 1/jour côté serveur | 2,5 | 1 500 € |
| Fil, publication, anonymat, états Gratuit/Premium | 3 | 1 800 € |
| Ameen + notifications + réglages | 1,5 | 900 € |
| Signalement + modération (admin existante) | 1,5 | 900 € |
| **Sous-total** | **8,5** | **5 100 €** |
| **3. Assistant IA de progression** | | |
| Agrégation des statistiques, stockage des conseils | 2 | 1 200 € |
| Génération IA : prompt borné, cache quotidien, 12 langues | 3 | 1 800 € |
| Dashboard, objectif du jour, actions directes | 2,5 | 1 500 € |
| Historique 30 conseils + suivi d'objectifs | 1,5 | 900 € |
| **Sous-total** | **9** | **5 400 €** |
| **4. Quiz Expert** | | |
| Modèle de données : catégories, types, explications, sources | 2 | 1 200 € |
| Sessions : 5/10/15, minuteur, 3 types, score et rangs | 4 | 2 400 € |
| Leaderboard hebdomadaire + badge + remise à zéro | 2 | 1 200 € |
| Pipeline d'import des packs mensuels | 1 | 600 € |
| **Sous-total** | **9** | **5 400 €** |
| **5. Récitateurs Premium** | | |
| Bibliothèque 10+, fiches, aperçus, badges, conversion | 2,5 | 1 500 € |
| Personnalisation audio (vitesse, répétition, enchaînement) | 1,5 | 900 € |
| **Sous-total** | **4** | **2 400 €** |
| **6. Pack Family** | | |
| Groupes, invitations lien/QR, droits partagés, règles de sortie | 4 | 2 400 € |
| Produit Family dans les stores + offre de lancement | 2 | 1 200 € |
| Dashboard famille | 2 | 1 200 € |
| Challenges collectifs, milestones, badges, notifications | 3,5 | 2 100 € |
| Battle Quiz temps réel (lobby, synchronisation, arbitrage serveur, reconnexion) | 8 | 4 800 € |
| Tests multi-appareils | 1,5 | 900 € |
| **Sous-total** | **21** | **12 600 €** |
| **7. Widgets iOS & Android** | | |
| iOS — WidgetKit : 4 widgets, 2 tailles, App Group, timeline | 4,5 | 2 700 € |
| Android — Glance : 4 widgets, rafraîchissement planifié | 3,5 | 2 100 € |
| Pont app ↔ widgets, gestion Premium, écran de configuration | 3 | 1 800 € |
| **Sous-total** | **11** | **6 600 €** |
| **TOTAL Partie 2** | **72,5** | **43 500 €** |

Fourchette avec provision pour imprévus : **43 000 – 48 000 €**.

**Délai :** 14 à 16 semaines à temps plein, en livraisons successives alignées sur les lots de design prévus pour Karim :

1. Socle Abonnements + Paywall *(préalable à tout)*
2. Mur des Dua · Récitateurs Premium
3. Quiz Expert · Assistant IA
4. Pack Family
5. Widgets

**Modalités de paiement proposées :** 30 % à la commande, puis paiement par jalon à chaque livraison, solde de 20 % à la livraison finale.

**Récapitulatif V2 complète** (Parties 1 + 2) : 117 jours · **69 000 – 77 500 €** · environ 6 mois à temps plein.

---

## 10. Points d'attention

**Le socle d'abonnements est un prérequis absolu.** Aucune fonctionnalité Premium ne peut être livrée sans lui. Il est aussi le poste le plus sensible en délais externes : validation des produits d'achat intégré par Apple et Google, comptes bancaires et fiscaux configurés dans App Store Connect et Play Console. Ces démarches côté client doivent être lancées dès la signature.

**RevenueCat.** Gratuit jusqu'à 2 500 $ de revenus mensuels, puis ~1 % des revenus suivis. C'est un coût d'exploitation modeste au regard de ce qu'il évite : la validation des reçus Apple/Google maison est un chantier notoirement piégeux que ce choix élimine.

**Le contenu du Quiz Expert n'est pas inclus.** Ce devis livre le moteur, les écrans et l'outil d'import ; la rédaction des questions des 5 catégories (avec sources vérifiées) et des packs mensuels est une prestation éditoriale et religieuse, pas un développement. Elle doit être confiée à une personne qualifiée, et le contenu validé religieusement — comme l'exigent vos propres spécifications pour l'IA.

**Coût d'exploitation de l'IA.** L'appel quotidien par utilisateur Premium est un coût récurrent du client (votre estimation de ~300 €/mois pour 10 000 Premium est réaliste avec un modèle économique type Haiku/GPT-mini). Le plafonnement à une requête/jour est appliqué côté serveur.

**Récitateurs : disponibilité des sources audio.** Les 9 récitateurs actuels proviennent d'une source intégrée. Si les récitateurs supplémentaires souhaités n'y figurent pas, il faudra héberger les fichiers (CDN) et vérifier les droits d'utilisation des enregistrements — coût et démarche à la charge du client, que je peux chiffrer une fois la liste des récitateurs arrêtée.

**« Personnalisation audio complète » à préciser.** Le chiffrage couvre vitesse, répétition et enchaînement continu. Toute ambition supplémentaire (égaliseur, téléchargement hors ligne massif…) devra faire l'objet d'un avenant.

**Battle Quiz : une alternative économique existe.** La version temps réel chiffrée ici est la plus fidèle aux spécifications, et la plus coûteuse. Une variante « au rythme de chacun » (chaque membre répond dans la journée, classement en fin de journée) diviserait ce sous-poste par deux tout en conservant la dynamique familiale. Je recommande la version temps réel — c'est l'argument de vente du Pack Family — mais le choix vous appartient.

**Widgets iOS : le rythme de 15 minutes n'est pas garanti par Apple.** Comme expliqué au poste 7, la timeline pré-générée garantit des horaires exacts à l'affichage ; en revanche, un widget « temps réel » au sens strict n'existe pas sur iOS, quel que soit le développeur. À annoncer tel quel dans la communication produit.

**Dépendances.** Infrastructure push de la Partie 1 (pour Ameen et milestones familiaux) ; maquettes de Karim par lots, le Lot 1 (dont le paywall) étant bloquant pour démarrer les écrans ; textes légaux des offres d'abonnement (CGV, mentions de renouvellement automatique exigées par Apple/Google) côté client.

---

*Devis valable 30 jours. Les montants s'entendent hors taxes.*
