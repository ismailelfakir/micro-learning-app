# 📱 Micro-Learning App

> Application mobile de micro-learning multiplateforme développée avec Flutter et SQLite

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-3.0+-003B57?logo=sqlite)](https://www.sqlite.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Table des matières

- [À propos](#-à-propos)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [Architecture](#-architecture)
- [Structure du projet](#-structure-du-projet)
- [Base de données](#-base-de-données)
- [Développement](#-développement)
- [Technologies utilisées](#-technologies-utilisées)
- [Contribution](#-contribution)
- [Licence](#-licence)

## 🎯 À propos

**Micro-Learning App** est une application mobile éducative permettant aux apprenants de :
- Consulter des contenus éducatifs courts (micro-learning)
- S'auto-évaluer via des quiz interactifs
- Accéder aux contenus en mode hors-ligne
- Suivre leur progression d'apprentissage

L'application fonctionne **entièrement en local** avec SQLite comme base de données et ne nécessite aucune connexion Internet après l'installation initiale.

### 🎓 Public cible

- Apprenants individuels
- Étudiants
- Professionnels en formation continue
- Toute personne souhaitant apprendre de manière autonome

## ✨ Fonctionnalités

### 🔐 Authentification
- **Inscription locale** : Création de compte utilisateur avec email et mot de passe
- **Connexion sécurisée** : Authentification avec hachage SHA-256
- **Gestion de session** : Persistance de la session utilisateur
- **Déconnexion** : Fermeture de session avec confirmation

### 📚 Catalogue de contenus
- **Catégories thématiques** : Organisation des leçons par domaines
- **Liste de leçons** : Affichage des leçons par catégorie
- **Filtrage** : Filtrage par type de contenu (TEXTE, IMAGE, PDF, VIDEO)
- **Détails de leçon** : Informations complètes sur chaque leçon

### 📖 Types de contenus supportés

#### 📝 Texte (TEXTE)
- Affichage de contenu textuel formaté
- Description détaillée de la leçon

#### 🖼️ Image (IMAGE)
- Support des images SVG et raster (PNG, JPG)
- Visualisation intégrée dans l'application

#### 📄 PDF (PDF)
- Lecteur PDF intégré avec navigation
- Zoom et défilement
- Support des PDFs locaux

#### 🎥 Vidéo (VIDEO)
- Lecteur vidéo intégré
- Contrôles de lecture (play/pause)
- Indicateur de progression
- Support des vidéos locales (1-3 minutes)

### 🧩 Système de quiz
- **Quiz par leçon** : Chaque leçon peut avoir un quiz associé
- **Questions à choix multiples (QCM)** : Une seule réponse correcte par question
- **Navigation séquentielle** : Une question à la fois
- **Calcul automatique du score** : Affichage du résultat à la fin
- **Évaluation immédiate** : Feedback instantané après chaque quiz

### 📥 Mode hors-ligne
- **Téléchargement de contenus** : Téléchargement de PDFs et vidéos pour accès hors-ligne
- **Gestion des téléchargements** : Suivi du statut de téléchargement
- **Stockage local** : Fichiers stockés dans le répertoire de l'application
- **Suppression** : Possibilité de supprimer les contenus téléchargés

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- **Flutter SDK** (version 3.0 ou supérieure)
  ```bash
  flutter --version
  ```
- **Dart SDK** (inclus avec Flutter)
- **Android Studio** ou **Xcode** (pour iOS)
- **Émulateur Android/iOS** ou **appareil physique**
- **Git** (pour cloner le projet)

### Vérification de l'installation

```bash
flutter doctor
```

Assurez-vous que tous les composants sont correctement configurés.

## 🚀 Installation

### 1. Cloner le dépôt

```bash
git clone <repository-url>
cd micro-learning-app
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Vérifier les assets

Assurez-vous que les fichiers suivants existent dans les dossiers `assets/` :
- `assets/pdfs/css_flexbox.pdf`
- `assets/videos/javascript_variables.mp4`
- `assets/images/dom_diagram.svg`

### 4. Lancer l'application

#### Sur Android
```bash
flutter run -d <device-id>
```

#### Sur iOS (macOS uniquement)
```bash
flutter run -d <device-id>
```

#### Lister les appareils disponibles
```bash
flutter devices
```

## ⚙️ Configuration

### Configuration de la base de données

La base de données SQLite est automatiquement initialisée au premier lancement de l'application. Les données de démonstration sont insérées automatiquement si les tables sont vides.

### Configuration des assets

Les assets sont déclarés dans `pubspec.yaml` :

```yaml
flutter:
  assets:
    - assets/pdfs/
    - assets/videos/
    - assets/images/
```

### Ajout de nouveaux contenus

Pour ajouter de nouveaux contenus :

1. **PDFs** : Placez vos fichiers dans `assets/pdfs/`
2. **Vidéos** : Placez vos fichiers dans `assets/videos/`
3. **Images** : Placez vos fichiers dans `assets/images/`

Les formats supportés :
- **PDF** : `.pdf`
- **Vidéo** : `.mp4`, `.mov`
- **Images** : `.svg`, `.png`, `.jpg`, `.jpeg`, `.webp`

## 📱 Utilisation

### Premier lancement

1. **Inscription** : Créez un compte avec votre email et mot de passe
2. **Connexion** : Connectez-vous avec vos identifiants
3. **Exploration** : Parcourez les catégories et leçons disponibles

### Navigation dans l'application

```
Accueil (Catégories)
    ↓
Liste des leçons (par catégorie)
    ↓
Détails de la leçon
    ├─→ Lecture du contenu
    ├─→ Quiz (si disponible)
    └─→ Téléchargement (PDF/VIDEO uniquement)
```

### Utilisation des fonctionnalités

#### 📖 Lire une leçon
1. Sélectionnez une catégorie
2. Choisissez une leçon
3. Consultez le contenu selon le type :
   - **TEXTE** : Contenu affiché directement
   - **IMAGE** : Image affichée dans l'écran
   - **PDF** : Cliquez sur "Ouvrir le PDF"
   - **VIDEO** : Cliquez sur "Lire la vidéo"

#### 🧩 Passer un quiz
1. Ouvrez une leçon avec quiz disponible
2. Cliquez sur "Commencer le quiz"
3. Répondez aux questions une par une
4. Consultez votre score à la fin

#### 📥 Télécharger pour mode hors-ligne
1. Ouvrez une leçon PDF ou VIDEO
2. Cliquez sur "Télécharger pour lecture hors-ligne"
3. Le contenu sera disponible même sans Internet
4. Pour supprimer : Cliquez sur "Supprimer le téléchargement"

#### 🔍 Filtrer les leçons
1. Dans la liste des leçons d'une catégorie
2. Utilisez les filtres en haut (Tous, TEXTE, IMAGE, PDF, VIDEO)
3. Les leçons sont filtrées en temps réel

## 🏗️ Architecture

L'application suit une **architecture feature-based** avec séparation claire des responsabilités :

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│         (Screens / UI Components)        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│           Service Layer                  │
│      (Business Logic / Services)         │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│            Data Layer                    │
│         (DAO / Database Access)          │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Core Layer                       │
│    (Models / Database / Utils)           │
└──────────────────────────────────────────┘
```

### Principes d'architecture

- **Séparation des responsabilités** : Chaque couche a un rôle précis
- **Feature-based** : Organisation par fonctionnalité métier
- **Dependency Injection** : Services injectés dans les widgets
- **Single Responsibility** : Chaque classe a une seule responsabilité

## 📁 Structure du projet

```
micro-learning-app/
│
├── lib/
│   ├── main.dart                          # Point d'entrée de l'application
│   │
│   ├── core/                              # Couche core (partagée)
│   │   ├── database/                      # Gestion de la base de données
│   │   │   ├── database_manager.dart      # Gestionnaire SQLite
│   │   │   ├── database_schema.dart      # Schéma de la base de données
│   │   │   ├── database_debug_helper.dart # Utilitaires de debug
│   │   │   └── database_debug_screen.dart # Écran de debug
│   │   │
│   │   ├── models/                        # Modèles de données
│   │   │   ├── user.dart                 # Modèle Utilisateur
│   │   │   ├── category.dart             # Modèle Catégorie
│   │   │   ├── lesson.dart                # Modèle Leçon
│   │   │   ├── quiz.dart                  # Modèle Quiz
│   │   │   ├── question.dart              # Modèle Question
│   │   │   ├── answer.dart                # Modèle Réponse
│   │   │   └── download.dart              # Modèle Téléchargement
│   │   │
│   │   └── services/                      # Services core
│   │       └── session_manager.dart       # Gestionnaire de session
│   │
│   ├── features/                          # Fonctionnalités métier
│   │   │
│   │   ├── auth/                          # Authentification
│   │   │   ├── data/
│   │   │   │   └── user_dao.dart          # Accès données utilisateur
│   │   │   ├── services/
│   │   │   │   └── auth_service.dart     # Logique d'authentification
│   │   │   └── screens/
│   │   │       ├── login_screen.dart      # Écran de connexion
│   │   │       ├── register_screen.dart   # Écran d'inscription
│   │   │       └── home_screen.dart        # Écran d'accueil (déprécié)
│   │   │
│   │   ├── catalog/                       # Catalogue de contenus
│   │   │   ├── data/
│   │   │   │   ├── category_dao.dart      # Accès données catégories
│   │   │   │   └── lesson_dao.dart       # Accès données leçons
│   │   │   ├── services/
│   │   │   │   ├── catalog_service.dart   # Service catalogue
│   │   │   │   └── seed_service.dart      # Service de données de démo
│   │   │   └── screens/
│   │   │       ├── categories_list_screen.dart    # Liste des catégories
│   │   │       ├── lessons_list_screen.dart        # Liste des leçons
│   │   │       └── lesson_detail_screen.dart        # Détails d'une leçon
│   │   │
│   │   ├── content_reader/                 # Lecture de contenus
│   │   │   ├── data/
│   │   │   │   └── download_dao.dart      # Accès données téléchargements
│   │   │   ├── services/
│   │   │   │   └── download_service.dart  # Service de téléchargement
│   │   │   └── screens/
│   │   │       ├── pdf_viewer_screen.dart  # Lecteur PDF
│   │   │       └── video_player_screen.dart # Lecteur vidéo
│   │   │
│   │   └── quiz/                           # Système de quiz
│   │       ├── data/
│   │       │   ├── quiz_dao.dart          # Accès données quiz
│   │       │   ├── question_dao.dart      # Accès données questions
│   │       │   └── answer_dao.dart        # Accès données réponses
│   │       ├── services/
│   │       │   └── quiz_service.dart      # Service quiz
│   │       └── screens/
│   │           ├── quiz_screen.dart        # Écran de quiz
│   │           └── quiz_result_screen.dart # Écran de résultats
│   │
│   └── ui/                                 # Composants UI réutilisables
│       ├── screens/                        # Écrans partagés
│       ├── widgets/                        # Widgets réutilisables
│       └── theme/                          # Thème de l'application
│
├── assets/                                 # Ressources statiques
│   ├── pdfs/                              # Fichiers PDF
│   │   └── css_flexbox.pdf
│   ├── videos/                            # Fichiers vidéo
│   │   └── javascript_variables.mp4
│   └── images/                            # Images
│       └── dom_diagram.svg
│
├── android/                                # Configuration Android
├── ios/                                    # Configuration iOS (si présent)
├── test/                                   # Tests unitaires
├── pubspec.yaml                            # Dépendances et configuration
├── pubspec.lock                            # Versions verrouillées
└── README.md                               # Ce fichier
```

## 🗄️ Base de données

### Schéma SQLite

L'application utilise SQLite avec les tables suivantes :

#### Tables principales

- **UTILISATEUR** : Informations des utilisateurs
- **CATEGORIE** : Catégories thématiques
- **LECON** : Leçons éducatives
- **QUIZ** : Quiz associés aux leçons
- **QUESTION** : Questions des quiz
- **REPONSE** : Réponses aux questions
- **TELECHARGEMENT** : Suivi des téléchargements

### Relations

```
UTILISATEUR (1) ──→ (N) TELECHARGEMENT
CATEGORIE (1) ──→ (N) LECON
LECON (1) ──→ (1) QUIZ
QUIZ (1) ──→ (N) QUESTION
QUESTION (1) ──→ (N) REPONSE
```

### Initialisation

La base de données est créée automatiquement au premier lancement avec :
- Tables créées selon le schéma
- Index pour optimiser les requêtes
- Données de démonstration insérées si les tables sont vides

## 💻 Développement

### Commandes utiles

```bash
# Installer les dépendances
flutter pub get

# Analyser le code
flutter analyze

# Formater le code
flutter format lib/

# Lancer les tests
flutter test

# Construire l'APK (Android)
flutter build apk

# Construire l'APP (iOS)
flutter build ios

# Nettoyer le projet
flutter clean
```

### Débogage

#### Console de débogage
```bash
flutter run --verbose
```

#### Accès à la base de données
L'application inclut un écran de débogage pour inspecter la base de données :
- Accès via `DatabaseDebugScreen`
- Visualisation des tables et données

### Bonnes pratiques

1. **Nommage** : Utilisez des noms clairs et descriptifs
2. **Commentaires** : Documentez les fonctions complexes
3. **Séparation** : Respectez l'architecture feature-based
4. **Tests** : Écrivez des tests pour les services critiques
5. **Formatage** : Utilisez `flutter format` avant chaque commit

### Ajout d'une nouvelle fonctionnalité

1. Créer le dossier dans `lib/features/`
2. Organiser en `data/`, `services/`, `screens/`
3. Créer les modèles dans `lib/core/models/` si nécessaire
4. Ajouter les routes dans `main.dart`
5. Tester la fonctionnalité

## 🛠️ Technologies utilisées

### Core
- **Flutter** : Framework de développement mobile
- **Dart** : Langage de programmation
- **SQLite** : Base de données relationnelle locale

### Packages principaux

| Package | Version | Usage |
|---------|---------|-------|
| `sqflite` | ^2.3.0 | Accès SQLite |
| `path_provider` | ^2.1.1 | Accès aux répertoires système |
| `shared_preferences` | ^2.2.2 | Stockage de préférences |
| `crypto` | ^3.0.3 | Hachage de mots de passe |
| `pdfx` | ^2.9.2 | Lecteur PDF |
| `video_player` | ^2.8.1 | Lecteur vidéo |
| `flutter_svg` | ^2.0.9 | Support SVG |

### Outils de développement

- **Flutter SDK** : Environnement de développement
- **Android Studio** : IDE recommandé
- **VS Code** : Alternative légère
- **Flutter DevTools** : Outils de débogage

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. **Fork** le projet
2. Créez une **branche** pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. **Commit** vos changements (`git commit -m 'Add some AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une **Pull Request**

### Guidelines de contribution

- Suivez l'architecture feature-based existante
- Écrivez du code propre et documenté
- Ajoutez des tests pour les nouvelles fonctionnalités
- Respectez les conventions de nommage Dart/Flutter

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème :

- Ouvrez une **issue** sur le dépôt
- Consultez la documentation technique : `PROJECT_TECHNICAL_SPEC.md`
- Vérifiez les logs de débogage dans la console

## 🎯 Roadmap

Fonctionnalités futures envisagées :

- [ ] Synchronisation cloud (optionnelle)
- [ ] Statistiques d'apprentissage
- [ ] Certificats de complétion
- [ ] Mode sombre
- [ ] Multilingue (i18n)
- [ ] Notifications de rappel
- [ ] Partage de contenus
