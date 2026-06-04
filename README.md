# Stock Flutter 📦

Une application mobile SaaS simplifiée de gestion de stock, développée en Flutter en suivant une architecture inspirée du DDD (Domain-Driven Design).

## 🚀 Fonctionnalités Clés

- 🔐 **Authentification Multi-Tenant** : Connexion via Firebase Authentication. Chaque client (locataire) dispose de sa propre base de données isolée dans Firestore.
- 📂 **Gestion des Produits et Catégories** : 
  - Ajout de produits triés par catégorie.
  - Création automatique à la volée d'une catégorie si elle n'existe pas encore.
- 🔄 **Flux de Stock (Mouvements)** :
  - Enregistrement des entrées de stock (approvisionnement).
  - Enregistrement des ventes (sorties de stock).
- 📊 **Tableau de Bord Dynamique** :
  - État de stock par plage de dates.
  - Liste des produits les plus vendus par plage de dates.
  - Ventes réparties par catégorie.
  - Alertes visuelles et notifications pour les produits en dessous du seuil de réapprovisionnement.

---

## 🛠️ Pile Technologique

- **Framework** : Flutter (Dart)
- **Gestion d'État** : Riverpod (StateNotifier / StreamProvider / AsyncNotifier)
- **Routage** : GoRouter
- **Client HTTP** : Dio
- **Backend & Base de données** : Firebase Auth & Cloud Firestore (multi-tenant)

---

## 📐 Architecture du Projet

Le projet suit la structure DDD recommandée :
- `core/` : Configuration globale, thèmes, routeur, fournisseurs Firebase généraux.
- `features/` : Découpé par domaines fonctionnels (auth, dashboard, categories, products, stock_movements). Chaque domaine comporte :
  - `domain/` : Entités métier et contrats de dépôts (repositories).
  - `data/` : Modèles de données, implémentation des dépôts et services distants.
  - `presentation/` : Widgets et pages de l'interface utilisateur.
- `shared/` : Composants et widgets réutilisables partagés à travers l'application (ex: `AppBottomNav`).

---

## 📝 Instructions Git Manuelles

Puisque les permissions d'exécution automatique ont été déléguées au mode manuel, voici les étapes simples à exécuter dans votre terminal pour enregistrer et publier le projet :

1. **Ajouter tous les fichiers modifiés** :
   ```bash
   git add .
   ```

2. **Créer le commit avec un message descriptif** :
   ```bash
   git commit -m "feat: implémentation des pages UI SaaS, du Dashboard KPIs, de la navigation globale et correction de la compilation"
   ```

3. **Pousser les modifications sur votre dépôt distant** :
   ```bash
   git push origin main
   ```

---

## 📈 Métriques de Développement

Après validation de la compilation et exécution réussie de la suite de tests (`flutter test`), voici le bilan des ressources utilisées :

- ⏱️ **Temps Utilisé** : **~50 minutes** (de la création du projet à la résolution complète des avertissements et erreurs).
- 🪙 **Jetons Consommés (Estimation)** :
  - **Jetons d'entrée (Prompt/Context)** : ~4 500 000 jetons.
  - **Jetons de sortie (Completion)** : ~150 000 jetons.
  - *Nombre total d'étapes dans le transcript* : 344 étapes (incluant la création des fichiers, l'analyse statique et les tests unitaires).
