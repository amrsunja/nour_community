# DEVIS. Nour V2 : Premium, Family Pack et onboarding

**Prestataire :** Amir, Développeur Senior (Flutter / Supabase)
**Client :** Kevin Mesana, Nour App
**Date :** octobre 2026 (remplace les versions précédentes)
**Références :** Nour Specs V2 Final, document « Nour V2. La pensée et le concept », maquettes Figma « Nour community », échanges avec le client d'octobre 2026
**Devis lié :** Nour V2 : Coran, Mur des Dua, streak et widgets (devis séparé)

---

## 1. Contexte

Ce devis couvre tout ce qui permet de vendre le Premium : les abonnements, le paywall, l'essai gratuit, le Quiz Expert, le Pack Family et la refonte de l'onboarding. Le second devis couvre le lecteur Coran, le Mur des Dua, le streak, les widgets et la finition des écrans.

Après nos échanges, le périmètre a été précisé :

- L'assistant IA et le Battle Quiz (y compris les défis asynchrones) sont retirés de la V2.
- Le Premium inclut un essai gratuit de 7 jours.
- Le Pack Family a une page dédiée où les membres voient la progression des autres et un top 5 selon l'ajr cumulé, filtrable par semaine, par mois et depuis le début.
- Nouvelles tâches par rapport au devis précédent : animations du paywall, paywall à la fin de l'onboarding, écran widgets dans l'onboarding, refonte des deep links, correction de l'écran Outils.

L'infrastructure de notifications push de la partie 1 (Mosquées) est réutilisée pour le Pack Family sans coût supplémentaire.

---

## 2. Détail des fonctionnalités

### 2.1. Abonnements, paywall et essai gratuit

Aujourd'hui, l'application n'a aucune infrastructure d'abonnement : Stripe ne sert qu'aux dons. Sans ce bloc, aucune fonctionnalité Premium ne peut être vendue. C'est donc la première chose à faire.

Tarifs : Premium 9,99 € par mois ou 59,99 € par an, Family 69,99 € la première année puis 89,99 € par an (et 14,99 € par mois si vous confirmez ce tarif, il n'apparaît pas dans la maquette).

**Achats via RevenueCat**
- Configuration des produits dans App Store Connect et Google Play Console, groupes d'abonnements, offerings RevenueCat.
- Essai gratuit de 7 jours pour le Premium, prix de lancement pour le Family. Ce sont les stores qui vérifient l'éligibilité à l'essai : un utilisateur n'y a droit qu'une fois.
- Restauration des achats, passage de Solo à Family.

**Statut d'abonnement côté serveur**
- Les webhooks RevenueCat (achat, renouvellement, annulation, expiration, remboursement, problème de paiement) sont enregistrés dans une table d'abonnements Supabase.
- Le statut Premium est calculé par une seule fonction serveur, utilisée par toute l'application. Ce n'est jamais le téléphone qui décide, la vérification ne peut pas être contournée.

**Écrans de paywall**
- Paywall principal (trois offres, essai gratuit, « Cancel anytime »), paywall du Mur des Dua, paywall des récitateurs, écran de bienvenue après l'achat, bannière Premium sur l'accueil.
- Belles animations sur les écrans de paywall : apparition des éléments, illustration animée, sélection fluide de l'offre, animation de célébration après l'achat.
- Une vérification d'accès unique pour toutes les fonctionnalités Premium. Si l'abonnement expire, l'utilisateur perd l'accès proprement et se voit proposer de renouveler, sans écran cassé.

**Paywall à la fin de l'onboarding**
- Logique d'affichage du paywall juste après l'onboarding : quand l'afficher, comment le passer, comment ne pas le remontrer à quelqu'un qui a déjà refusé ou déjà acheté.
- Objectif : l'utilisateur termine l'onboarding, comprend ce que le Premium apporte et peut lancer l'essai gratuit tout de suite.

### 2.2. Onboarding, navigation et deep links

**Écran widgets dans l'onboarding**
- Nouvelle étape dans l'onboarding, uniquement pour le profil utilisateur (pas pour le profil mosquée).
- Elle montre à quoi ressemblent les widgets et propose de les ajouter à l'écran d'accueil. Sur Android, le widget peut être ajouté directement depuis l'application. Sur iOS, le système ne le permet pas, il y aura donc des instructions claires, étape par étape.

**Refonte des deep links**
- Tous les liens passent par un seul schéma : universal links sur iOS, app links sur Android, un seul point d'entrée dans la navigation.
- Nécessaire pour les invitations au Pack Family, les ouvertures depuis les notifications, les appuis sur les widgets et les liens de partage.
- Le lien fonctionne même si l'application n'est pas installée : la personne arrive sur le store, puis l'écran voulu s'ouvre après l'installation.

**Correction de l'écran Outils**
- Les actions du jour (daily actions) restent uniquement sur l'écran d'accueil (dashboard).
- L'écran Outils ne contient plus que les outils.

### 2.3. Quiz Expert

Les niveaux Débutant et Intermédiaire restent inchangés et gratuits.

- Modèle de données : 5 catégories (Coran, Hadith, Sîra, Fiqh, Histoire islamique), trois types de questions (QCM à 4 choix, vrai ou faux, texte à compléter), explication détaillée et source pour chaque question.
- Session : 5, 10 ou 15 questions, minuteur de 30 secondes en option, écran d'explication après chaque réponse.
- Un utilisateur gratuit peut essayer une question du niveau Expert, puis se voit proposer le Premium.
- Progression par catégorie : les thèmes déjà maîtrisés et ceux à retravailler.
- Script d'import des nouvelles questions depuis un tableur (même format FR/EN/AR que les quiz actuels).

La rédaction des questions n'est pas incluse dans ce devis.

### 2.4. Pack Family

**Groupe et abonnement**
- Le titulaire du pack et jusqu'à 4 membres. Un utilisateur ne peut faire partie que d'un seul groupe.
- Le Premium des membres est calculé côté serveur à partir de l'abonnement du titulaire. Un membre qui quitte le groupe repasse immédiatement en gratuit. Si le titulaire résilie, tout le groupe perd le Premium.
- États prévus : places restantes, invitation en attente, membre parti, groupe complet.

**Inviter et partager**
- Le titulaire partage un lien par n'importe quelle application (WhatsApp, Telegram, SMS, etc.). Le lien est valable 48 heures.
- Si l'invité n'a pas l'application, le lien l'envoie sur le store, puis l'écran « Rejoindre le pack » et l'inscription s'ouvrent après l'installation.
- Le serveur vérifie la limite de 5 personnes et la règle d'un seul groupe par utilisateur.

**Page de progression de la famille**
- Chaque membre voit la progression des autres : ajr, streak, activité du jour.
- Top 5 des membres selon l'ajr cumulé, avec un filtre : semaine, mois, depuis le début. Le but est de donner à la famille l'envie de cumuler de l'ajr et de pratiquer plus souvent.
- L'ajr est déjà enregistré côté serveur (`ajr_log`, `daily_activity`). Il faut une fonction serveur rapide pour les calculs par période et des règles d'accès pour que chacun ne voie que son propre groupe.
- Les données personnelles (journal, duas personnelles) restent privées.

**Objectifs familiaux**
- Objectifs communs : dhikr en famille, quiz, une dua par jour, Ramadan, lecture du Coran.
- La progression est calculée automatiquement à partir de l'activité de chacun, avec une notification à tous les membres à chaque étape atteinte.

---

## 3. Prix

Prix forfaitaire pour l'ensemble des travaux décrits dans la section 2.

| Fonctionnalité | Montant |
|---|---|
| 2.1. Abonnements, paywall, essai gratuit de 7 jours, animations, paywall de fin d'onboarding | 1 300 € |
| 2.2. Écran widgets dans l'onboarding, refonte des deep links, correction de l'écran Outils | 500 € |
| 2.3. Quiz Expert | 800 € |
| 2.4. Pack Family (groupe, invitation par lien, page de progression et top 5 par ajr, objectifs familiaux) | 1 300 € |
| **TOTAL** | **3 900 €** |

---

## 4. Délais et paiement

**Délai :** environ 3 semaines après la signature, hors délais de validation Apple et Google et hors attente des maquettes manquantes.

**Paiement :**
- 30 % à la signature : 1 170 €
- 50 % à la livraison de la version de test (TestFlight et test interne Google Play) : 1 950 €
- 20 % à la mise en production : 780 €

---

## 5. Points importants

**Les abonnements doivent être lancés tout de suite.** Sans eux, aucune fonctionnalité Premium ne fonctionne, y compris celles du second devis. De votre côté, dès la signature : contrat Paid Apps, informations fiscales et bancaires dans App Store Connect et Google Play Console, programme Small Business d'Apple (commission de 15 %), textes légaux de l'abonnement (conditions, renouvellement automatique, conditions de l'essai gratuit).

**RevenueCat.** Gratuit jusqu'à 2 500 $ de revenus par mois, puis environ 1 % (selon la grille actuelle de RevenueCat). C'est beaucoup moins cher et plus fiable que de développer soi-même la vérification des reçus Apple et Google.

**Top 5 du Pack Family.** Le document concept d'août excluait les classements. Ici, nous faisons volontairement un top 5, mais uniquement à l'intérieur d'une famille. Personne d'autre ne le voit.

**Questions du Quiz Expert.** Elles ne sont pas incluses. C'est un travail éditorial à part, avec vérification des sources.

**Ce dont j'ai besoin de votre part :** les maquettes manquantes (Quiz Expert, page de progression de la famille, écran widgets de l'onboarding) et la relecture des traductions.

---

*Devis valable 30 jours. Les montants s'entendent hors taxes.*
