# Devis — Module Mosquées & Infrastructure Notifications Push

**Nour App — V2**

**Prestataire :** Amir — Développeur Senior (Flutter / Supabase)
**Client :** Kevin Mesana — Nour App
**Date :** août 2026
**Références :** Nour Specs V2 Final (section 7) · maquettes Donation / Dashboard Mosquée / Membership

---

## 1. Objet du devis

Ce devis couvre deux chantiers distincts mais liés :

**Le module Mosquées**, une plateforme à deux faces intégrée dans Nour. Côté utilisateur : recherche de mosquées, fiche complète avec horaires de prière, services, annonces et événements, abonnement aux notifications, dons ponctuels et récurrents, participation aux collectes, adhésion comme membre. Côté mosquée : un tableau de bord complet pour gérer son profil, ses horaires, ses annonces, ses campagnes de dons, ses membres et ses statistiques.

**L'infrastructure de notifications push**, un socle technique transversal dont le module Mosquées a besoin, mais qui servira aussi aux autres fonctionnalités V2 (notifications Ameen du Mur des Dua, milestones du Pack Family). Je la présente ici comme un poste séparé car c'est une brique indépendante, développée une seule fois et réutilisée partout.

Sur le plan financier, l'architecture retenue est **Stripe Connect en direct charges** : chaque mosquée connecte son propre compte Stripe et reçoit les dons directement sur son compte bancaire. Nour ne détient, ne redistribue et ne touche jamais les fonds — la plateforme ne fait que traiter les données de transaction pour alimenter les statistiques et l'interface. Le bénéficiaire juridique du paiement (merchant of record) est la mosquée elle-même.

---

## 2. Poste 1 — Infrastructure Notifications Push (Firebase Messaging + Supabase)

Aujourd'hui, l'application ne gère que des rappels locaux programmés sur le téléphone. Aucune notification ne peut être envoyée depuis le serveur. Or le module Mosquées repose entièrement sur cette capacité : sans elle, pas de notifications aux abonnés d'une mosquée, pas d'alertes d'événements, pas de relances de campagnes.

### Ce qui sera mis en place

- Intégration de **Firebase Cloud Messaging** dans l'application Flutter, avec la configuration native iOS (certificats APNs, capabilities, gestion des permissions) et Android (canaux de notification).
- Enregistrement et cycle de vie des **tokens d'appareils** en base Supabase : création à la connexion, rafraîchissement automatique, nettoyage des tokens expirés, gestion multi-appareils par utilisateur.
- **Fonction d'envoi côté serveur** (Supabase Edge Function) : c'est le serveur qui décide qui reçoit quoi. Envoi unitaire, envoi par segment (ex. tous les abonnés d'une mosquée), gestion des erreurs et des tokens invalides retournés par FCM.
- **Préférences de notification** par utilisateur : écran de réglages permettant d'activer ou désactiver chaque type de notification indépendamment.
- **Deep links** : une notification ouvre directement le bon écran (fiche mosquée, événement, campagne).
- Journal des envois en base, qui servira ensuite aux statistiques d'ouverture des mosquées.

Cette brique est développée en amont du module Mosquées et livrée séparément, ce qui permet de la tester isolément et de la réutiliser telle quelle pour le Mur des Dua et le Pack Family sans coût supplémentaire.

---

## 3. Poste 2 — Module Mosquées

### Bloc A — Socle (spécifications V2, section 7)

**A1. Recherche de mosquée.** Recherche par nom, ville ou adresse, et mode « autour de moi » basé sur la géolocalisation avec calcul de distance (extension PostGIS côté base de données). Résultats avec nom, photo, distance et note. Chaque utilisateur peut définir une mosquée principale et une mosquée secondaire.

**A2. Fiche mosquée (4 onglets).**
- *Informations :* photo de couverture, logo, nom, adresse avec copie rapide, bouton itinéraire (ouverture du GPS), téléphone, email, site web, réseaux sociaux, description, statut ouvert/fermé, compteurs d'abonnés et de membres.
- *Horaires :* les 5 prières quotidiennes et les horaires de Joumou'a.
- *Services :* la liste des ~11 services (espace femmes, accès handicapé, parking, salle d'ablution, cours enfants/adultes, cours de Qur'an, cours d'arabe, janaza, iftar Ramadan, bibliothèque, accompagnement des nouveaux musulmans).
- *Annonces & Événements :* annonces actives, événements avec bouton « Ajouter à mon calendrier » — export d'un fichier .ics, sans connexion aux comptes Google ou Apple.

**A3. Abonnement (Follow).** Boutons s'abonner / se désabonner, réception des notifications de la mosquée via l'infrastructure push du Poste 1.

**A4. Dashboard mosquée.** Un tableau de bord à onglets : édition du profil (avec upload de logo et couverture), saisie des horaires, cases à cocher des services, gestion des annonces (2 actives maximum), gestion des événements (3 actifs maximum), envoi de notifications aux abonnés avec une limite de 1 à 2 par semaine appliquée côté serveur, et un onglet statistiques : nombre d'abonnés, vues du profil, taux d'ouverture des notifications.

**A5. Enregistrement et vérification des mosquées.** Point absent des spécifications mais indispensable : il faut un processus pour qu'un responsable de mosquée revendique sa mosquée. Je mets en place le formulaire de demande, l'écran de modération dans l'admin Nour existante (approuver / refuser), le rôle d'administrateur de mosquée et les règles de sécurité en base garantissant que chaque responsable ne peut modifier que sa propre mosquée. Le traitement opérationnel des demandes (vérifier les documents, rappeler la mosquée) reste à la charge du client.

### Bloc B — Dons et collectes (d'après les maquettes)

**B1. Onboarding Stripe Connect.** Depuis son dashboard, la mosquée clique sur « Activer les dons » et est redirigée vers le parcours d'inscription hébergé par Stripe (vérification d'identité, coordonnées bancaires — tout est contrôlé par Stripe, pas par nous). Les dons ne s'ouvrent qu'une fois le compte validé. Un écran d'état affiche où en est la mosquée : non commencé, en cours, actif, documents requis.

**B2. Fonds général « Sadaqah ».** La collecte permanente pour les besoins quotidiens de la mosquée. L'utilisateur choisit le type — ponctuel, mensuel ou annuel — un montant prédéfini (10 / 50 / 100 / 150 €) ou un montant libre, puis paie via la feuille de paiement native Stripe : carte, Apple Pay, Google Pay. Pas de webview. Les dons récurrents sont des abonnements Stripe sur le compte de la mosquée ; l'utilisateur retrouve la liste de ses dons récurrents dans son profil et peut les annuler à tout moment.

**B3. Campagnes de collecte.** La mosquée crée des collectes ciblées : titre, description, photo, objectif en euros, date limite (3 campagnes actives maximum). Côté utilisateur : carte de campagne avec barre de progression « collecté / objectif », nombre de donateurs, jours restants, boutons Contribuer et Partager (lien profond vers la campagne). La progression se met à jour en temps réel. Les campagnes se clôturent automatiquement à échéance.

**B4. Adhésion (Become a member).** Formulaire d'adhésion : prénom, nom, date de naissance, profession, email, téléphone, disponibilité pour le bénévolat, case de consentement RGPD. Cotisation annuelle optionnelle (60 / 120 / 240 € ou montant libre) — l'adhésion reste possible gratuitement. La cotisation est un abonnement annuel Stripe. La mosquée dispose de la liste de ses membres avec export CSV.

**B5. Analytique financière de la mosquée.** L'onglet Donation du dashboard, tel que maquetté : total collecté sur l'année avec comparaison à l'année précédente, répartition Soutien / Campagnes en montants et pourcentages, nombre de donateurs, donateurs récurrents, don moyen ; le détail du fonds Sadaqah ; la gestion des campagnes ; la **liste des donateurs** (avec option de don anonyme) filtrable et exportable ; et les **reçus fiscaux** : génération automatique d'un PDF par don ou d'un récapitulatif annuel, envoyé par email au donateur, dans un format compatible avec le reçu fiscal français — la responsabilité juridique du droit d'émettre ces reçus restant celle de la mosquée (voir section 7).

**B6. Logique serveur des paiements.** Les fonctions serveur : création des paiements et abonnements sur le compte connecté (le montant et la campagne sont validés côté serveur — le client ne fixe jamais un prix), traitement des webhooks Stripe de manière idempotente sur le modèle du système de paiement existant, synchronisation des statuts d'abonnements. Chaque don est enregistré dans notre base : c'est ce qui alimente toute l'analytique. En option, un mode de repli « lien externe » pour les mosquées qui refusent Stripe (simple bouton, sans statistiques).

---

## 4. Écrans livrés

| # | Écran |
|---|---|
| 1 | Réglages de notifications (Poste 1) |
| 2 | Recherche mosquée (liste + géolocalisation) |
| 3 | Fiche mosquée — 4 onglets |
| 4 | Formulaire de don (type, montant, paiement) |
| 5 | Fiche campagne + contribution |
| 6 | Adhésion membre |
| 7 | Mes dons / mes dons récurrents (profil utilisateur) |
| 8 | Demande d'enregistrement de mosquée |
| 9 | Dashboard mosquée — onglets de gestion |
| 10 | Dashboard mosquée — onglet Donation (analytique, campagnes, donateurs, reçus) |
| 11 | Statut onboarding Stripe |
| 12 | Modération des demandes (admin Nour existante) |

Auxquels s'ajoutent les états vides, chargements et erreurs pour chaque écran.

---

## 5. Base de données et serveur

Nouvelles tables : profils de mosquées avec coordonnées géographiques, administrateurs de mosquée, demandes d'enregistrement, horaires de prière, services, annonces, événements, abonnés, historique des notifications, vues de profil, comptes Stripe connectés, campagnes, dons, abonnements récurrents, membres, reçus émis, tokens d'appareils (Poste 1).

Modifications de l'existant : activation de l'extension PostGIS pour la recherche géographique ; politiques de sécurité (RLS) sur toutes les nouvelles tables — lecture publique des mosquées vérifiées, écriture réservée à l'administrateur de sa propre mosquée, chaque donateur ne voyant que ses propres dons ; déclencheur de mise à jour du montant collecté des campagnes sur le modèle du système de paiement actuel ; publication temps réel sur les campagnes et les dons ; deux espaces de stockage (médias publics des mosquées, reçus privés).

Nouvelles fonctions serveur : onboarding Stripe Connect, création de don/abonnement, webhook Stripe dédié, envoi de notifications avec limitation de fréquence, génération de reçus PDF, recherche géographique, et la fonction d'envoi push générique du Poste 1.

---

## 6. Chiffrage

| Poste | Jours | Montant |
|---|---|---|
| **Poste 1 — Infrastructure Push (FCM + Supabase)** | | |
| Intégration FCM iOS/Android, tokens, permissions | 2,5 | 1 500 € |
| Fonction d'envoi serveur, segments, journal | 2 | 1 200 € |
| Préférences utilisateur + deep links | 1 | 600 € |
| **Sous-total Poste 1** | **5,5** | **3 300 €** |
| **Poste 2 — Bloc A : Socle Mosquées** | | |
| A1. Recherche + géolocalisation (PostGIS) | 3 | 1 800 € |
| A2. Fiche mosquée, 4 onglets, export .ics | 4 | 2 400 € |
| A3. Abonnement + branchement push | 2 | 1 200 € |
| A4. Dashboard mosquée + statistiques | 7 | 4 200 € |
| A5. Enregistrement, vérification, rôles et sécurité | 3 | 1 800 € |
| **Sous-total Bloc A** | **19** | **11 400 €** |
| **Poste 2 — Bloc B : Dons et collectes** | | |
| B1. Onboarding Stripe Connect | 3 | 1 800 € |
| B2. Sadaqah : don ponctuel + récurrent | 4 | 2 400 € |
| B3. Campagnes : gestion, temps réel, partage | 3,5 | 2 100 € |
| B4. Adhésion : formulaire + cotisation + export | 2,5 | 1 500 € |
| B5. Analytique + liste donateurs + reçus fiscaux | 4 | 2 400 € |
| B6. Fonctions serveur, webhooks, tests de paiement | 3 | 1 800 € |
| **Sous-total Bloc B** | **20** | **12 000 €** |
| *Option : lien de don externe (repli sans Stripe)* | *1,5* | *900 €* |
| *Option : système de notation des mosquées* | *2,5* | *1 500 €* |
| **TOTAL (hors options)** | **44,5** | **26 700 €** |

Fourchette avec provision pour imprévus : **26 000 – 29 500 €**.

**Délai :** 9 à 11 semaines à temps plein, en trois livraisons : Poste 1 (push), puis Bloc A (mosquées sans paiement), puis Bloc B (dons).

**Modalités de paiement proposées :** 30 % à la commande · 30 % à la livraison du Bloc A · 40 % à la livraison du Bloc B.

---

## 7. Points d'attention

**L'argent ne transite jamais par Nour — à formaliser par écrit.** Avec les direct charges, le bénéficiaire du paiement est la mosquée, la vérification d'identité est faite par Stripe, et les litiges ou remboursements relèvent de la mosquée. Nour est une plateforme technique. C'est exactement ce qui répond à votre préoccupation sur le risque et la responsabilité — mais il faut l'inscrire dans les CGU destinées aux mosquées (à faire valider par votre juriste).

**Reçus fiscaux.** Toutes les associations n'ont pas le droit d'émettre des reçus fiscaux (distinction loi 1901 / 1905, cultuelle / culturelle). L'application génère le PDF au nom de la mosquée ; celle-ci déclare lors de son inscription qu'elle a le droit d'en émettre. La responsabilité reste la sienne.

**App Store et Google Play.** Les dons aux organismes sans but lucratif sont autorisés hors achat intégré (guideline Apple 3.2.2) : la commission de 15–30 % des stores ne s'applique pas, et le paiement Stripe natif est conforme. Apple peut demander lors de la review une preuve du statut non lucratif des bénéficiaires — le processus de vérification des mosquées (A5) sert aussi à cela.

**Frais Stripe.** Environ 1,5–2,5 % + 0,25 € par transaction, à la charge de la mosquée, déduits du don. Ce sera affiché clairement lors de l'onboarding.

**La monétisation V3 est déjà prévue dans l'architecture.** Le jour où « Mosquée Pro » arrive, une commission de plateforme s'ajoute par un simple paramètre dans l'appel de paiement existant, sans rien reconstruire.

**Limites d'envoi côté serveur.** Le plafond de 1 à 2 notifications par semaine est appliqué par le serveur, pas seulement dans l'interface — sinon certaines mosquées finiront par lasser leurs abonnés.

**Dons anonymes.** Les maquettes montrent des avatars de donateurs : une option « donner anonymement » est prévue (la mosquée voit « Anonyme », les compteurs publics n'affichent que le nombre).

**Demandes concurrentes.** Deux personnes peuvent revendiquer la même mosquée. L'outil de modération permet de trancher ; la vérification elle-même (documents, appel téléphonique) est un processus opérationnel côté client.

**Taux d'ouverture des notifications.** Cette métrique du dashboard repose sur le suivi des ouvertures ; iOS ne remonte pas toujours les données de livraison, la mesure sera donc une estimation fiable mais pas exacte — autant l'annoncer honnêtement aux mosquées.

**Hors périmètre :** contenu et photos des mosquées, traitement opérationnel des vérifications, validation juridique des statuts associatifs, maquettes design (Karim), traduction du contenu saisi par les mosquées.

---

*Devis valable 30 jours. Les montants s'entendent hors taxes.*
