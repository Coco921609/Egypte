# 🇪🇬 Égypte

> **Voyagez en Égypte en toute sérénité.**

Découvrez l’Égypte autrement avec une application pensée pour vous accompagner dans la préparation de votre voyage. Explorez les destinations incontournables, découvrez la culture égyptienne et retrouvez des informations utiles dans une seule application.

## ✨ À propos de l’application

**Égypte** est une application mobile développée avec **Flutter**. Elle propose un guide de découverte du pays à travers ses villes, ses paysages, son patrimoine et sa culture.

Que vous prépariez votre premier séjour ou que vous souhaitiez simplement découvrir les merveilles égyptiennes, l’application vous invite à explorer le pays à votre rythme.

## 📲 Aperçu réel de l’application

Cette galerie présente des captures réalisées automatiquement depuis l’application Flutter exécutée dans Chromium au format mobile. Le workflow suit le parcours de navigation réel : choix de la langue, présentation, création du profil, accueil, paramètres et ouverture des différentes rubriques.

| Écran | Capture réelle |
|---|---|
| Choix de la langue | ![Choix de la langue](docs/screenshots/01-choix-langue.png) |
| Présentation – découverte | ![Présentation découverte](docs/screenshots/02-presentation-decouverte.png) |
| Présentation – expériences | ![Présentation expériences](docs/screenshots/03-presentation-experiences.png) |
| Présentation – bienvenue | ![Présentation bienvenue](docs/screenshots/04-presentation-bienvenue.png) |
| Création du profil | ![Création du profil](docs/screenshots/05-creation-profil.png) |
| Accueil | ![Accueil](docs/screenshots/06-accueil.png) |
| Paramètres | ![Paramètres](docs/screenshots/07-parametres.png) |
| Le Caire | ![Le Caire](docs/screenshots/08-le-caire.png) |
| Alexandrie | ![Alexandrie](docs/screenshots/09-alexandrie.png) |
| Louxor | ![Louxor](docs/screenshots/10-louxor.png) |
| Assouan | ![Assouan](docs/screenshots/11-assouan.png) |
| Siwa | ![Siwa](docs/screenshots/12-siwa.png) |
| Fayoum | ![Fayoum](docs/screenshots/13-fayoum.png) |
| Désert | ![Désert](docs/screenshots/14-desert.png) |
| Charm el-Cheikh | ![Charm el-Cheikh](docs/screenshots/15-sharm-el-sheikh.png) |
| Hurghada | ![Hurghada](docs/screenshots/16-hurghada.png) |
| Gastronomie | ![Gastronomie](docs/screenshots/17-gastronomie.png) |
| Hiéroglyphes | ![Hiéroglyphes](docs/screenshots/18-hieroglyphes.png) |

Les images sont générées par GitHub Actions à partir du vrai code de l’application. Elles ne sont pas des maquettes ni des illustrations de remplacement. Le workflow vérifie également qu’au moins 18 fichiers de capture ont été produits avant de les enregistrer dans le dépôt.

## 🏛️ Destinations à découvrir

L’application présente plusieurs régions et destinations d’Égypte :

- **Le Caire** – découvrez la capitale, son histoire et ses sites emblématiques.
- **Alexandrie** – explorez la ville méditerranéenne et son patrimoine.
- **Louxor** – plongez au cœur de l’Égypte antique.
- **Assouan** – découvrez le Nil et les paysages du sud.
- **Siwa** – partez à la découverte de l’oasis et du désert.
- **Fayoum** – explorez ses lacs et ses paysages naturels.
- **Le désert** – découvrez les grands espaces et les paysages désertiques.
- **Charm el-Cheikh** – profitez de la mer Rouge et de ses environs.
- **Hurghada** – découvrez une autre destination incontournable de la mer Rouge.

## 🖼️ Quelques destinations en images

| Le Caire | Alexandrie |
|:---:|:---:|
| ![Le Caire](assets/images/le%20caire.jpg) | ![Alexandrie](assets/images/alexandrie.jpg) |
| **Louxor** | **Assouan** |
| ![Louxor](assets/images/louxor.jpg) | ![Assouan](assets/images/assouan.jpg) |
| **Siwa** | **Fayoum** |
| ![Siwa](assets/images/siwa.jpeg) | ![Fayoum](assets/images/fayoum.jpeg) |
| **Le désert** | **Charm el-Cheikh** |
| ![Le désert](assets/images/R.jpg) | ![Charm el-Cheikh](assets/images/sharm.jpg) |
| **Hurghada** | |
| ![Hurghada](assets/hurgada/ile.jpg) | |

## 🌍 Fonctionnalités

- **Découverte des destinations :** des pages consacrées aux principales régions touristiques du pays.
- **Culture et patrimoine :** des contenus pour découvrir l’histoire, les hiéroglyphes et les traditions égyptiennes.
- **Gastronomie :** une découverte de la cuisine et des spécialités locales.
- **Application multilingue :** interface disponible en français, en anglais et en arabe.
- **Profil personnalisé :** possibilité de configurer son profil et certains éléments de personnalisation.
- **Expérience mobile :** une navigation conçue pour consulter les informations facilement.

## 🛠️ Technologies utilisées

- [Flutter](https://flutter.dev/) – développement de l’application.
- [Dart](https://dart.dev/) – langage de programmation.
- [Google Fonts](https://pub.dev/packages/google_fonts) – typographie.
- [GetX](https://pub.dev/packages/get) – gestion de certaines fonctionnalités et de la navigation.
- [Shared Preferences](https://pub.dev/packages/shared_preferences) – sauvegarde locale des préférences.
- [URL Launcher](https://pub.dev/packages/url_launcher) – ouverture de liens externes.

## 🚀 Lancer le projet

Assurez-vous d’avoir installé [Flutter](https://docs.flutter.dev/get-started/install), puis clonez le dépôt :

```bash
git clone https://github.com/Coco921609/Egypte.git
cd Egypte
```

Installez les dépendances :

```bash
flutter pub get
```

Lancez l’application :

```bash
flutter run
```

Pour générer une version Web :

```bash
flutter build web --base-href "/Egypte/"
```

## 📁 Structure du projet

```text
Egypte/
├── assets/
│   └── images/        # Images des destinations
├── lib/               # Code source Flutter
├── test/              # Tests du projet
├── pubspec.yaml       # Dépendances et ressources
└── README.md          # Présentation du projet
```

## 📱 Télécharger l’application

| Plateforme | Accès |
|---|---|
| **Android** | [Télécharger sur Google Play](https://play.google.com/store/apps/details?id=com.egypte) |
| **iPhone / iPad (version Web)** | [Ouvrir l’application sur GitHub Pages](https://coco921609.github.io/Egypte/) |

## 🔗 Liens

- **Dépôt GitHub :** [Coco921609/Egypte](https://github.com/Coco921609/Egypte)
- **Documentation Flutter :** [docs.flutter.dev](https://docs.flutter.dev/)

---

**Égypte – Voyagez en Égypte en toute sérénité.** 🇪🇬
