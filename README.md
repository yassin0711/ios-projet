# Matbakhi (مطبخي) — mini-projet iOS

Application de recettes en SwiftUI : recettes du monde et de Tunisie (API TheMealDB), favoris,
planning des repas de la semaine et liste de courses (Firebase).

> Le nom et l'angle « Tunisie + planning + liste de courses » rendent le sujet distinct d'une simple app
> de recettes : les projets similaires entre équipes sont notés 0.

📘 **Vous débutez en Swift ?** Lisez [GUIDE_DU_PROJET.md](GUIDE_DU_PROJET.md) : il explique le projet
fichier par fichier, avec les notions du cours.

## Exigences du sujet → où elles sont traitées

| Exigence | Implémentation | État |
|---|---|---|
| SwiftUI | Toute l'app | ✅ |
| Firebase Authentication (email/mot de passe + Google) | `AuthService` : Connexion, Inscription, Mot de passe oublié, bouton Google | ✅ (à tester avec le fichier Firebase) |
| Cloud Firestore | Profil, favoris, planning, liste de courses, en temps réel | ✅ |
| Au moins 9 interfaces | 14 interfaces (voir ci-dessous) | ✅ |
| Navigation | `TabView` + `NavigationStack` + sheets | ✅ (à compléter) |
| Formulaires avec validation | `Validation` + `FormField` : connexion, inscription, mot de passe oublié, ajouter un article | ✅ |
| API REST | TheMealDB (gratuite, sans clé) via `MealRepository` | ✅ |
| Animations | Splash, présentation, cartes (rebond au toucher), ingrédients qui apparaissent un par un, cœur des favoris qui rebondit, articles cochés, chargement | ✅ |
| Thème clair / sombre modifiable | Réglages → Apparence | ✅ |
| Multilingue FR / EN / AR (droite à gauche) | Réglages → Langue | ✅ |
| Chargement, erreurs, états vides | `LoadState` + `LoadingStateView` / `ErrorStateView` / `ContentUnavailableView` | ✅ |
| Google Mobile Ads : Banner + Interstitial (ID de test) | Bannière en bas de l'accueil, interstitielle toutes les 3 recettes ouvertes (`Ads.swift`) | ✅ |
| Bonus : hors ligne | Firestore garde une copie des favoris, du planning et des courses sur le téléphone | à vérifier en mode avion |

## Les écrans

| # | Écran | État |
|---|---|---|
| 1 | Splash animé | ✅ |
| 2 | Présentation (3 pages) | ✅ |
| 3 | Connexion (email + Google) | ✅ |
| 4 | Inscription | ✅ |
| 5 | Mot de passe oublié | ✅ |
| 6 | Accueil (recette du jour, catégories, saveurs de Tunisie) | ✅ |
| 7 | Recherche | ✅ |
| 8 | Liste par catégorie / cuisine | ✅ |
| 9 | Détail d'une recette (+ boutons favori, planning, courses) | ✅ |
| 10 | Favoris | ✅ |
| 11 | Planning de la semaine | ✅ |
| 12 | Liste de courses | ✅ |
| 13 | Ajouter un article (formulaire avec validation) | ✅ |
| 14 | Réglages (+ compte et déconnexion) | ✅ |

Pour garder un mini-projet simple, la communauté, la création de recettes et le profil ne sont pas prévus.

## Répartition dans l'équipe

Chaque membre doit pouvoir présenter et expliquer sa partie.

| Membre | Partie | Écrans |
|---|---|---|
| 1 | Authentification : Firebase Auth, Google Sign-In, validation des formulaires | 3, 4, 5 |
| 2 | API et découverte : Repository, Codable, états chargement/erreur/vide | 6, 7, 8, 9 |
| 3 | Firestore : favoris, planning, liste de courses, formulaire « Ajouter un article » | 10, 11, 12, 13 |
| 4 | Expérience : thème, langues, animations, publicités AdMob, bonus | 1, 2, 14 + pubs |

À 3 membres : les tâches du membre 4 sont réparties entre les membres 1 et 2.

## Architecture (MVVM + Repository, chapitres 3, 5 et 6)

```
View (SwiftUI)  →  ViewModel (ObservableObject, @Published)  →  Repository (protocol)  →  API / Firestore
```

```
Matbakhi/
├── Matbakhi.xcodeproj       Projet Xcode prêt à l'emploi (SDK, réglages)
├── Info.plist               Identifiant de test des pubs, retour de la connexion Google
├── Matbakhi/
│   ├── MatbakhiApp.swift    Point d'entrée (@main)
│   ├── Models/              Meal, MealCategory, thème et langue, LoadState, Validation
│   ├── Services/            API, connexion, Firestore (favoris, planning, courses), publicités
│   ├── ViewModels/          Un ViewModel par écran qui charge l'API
│   ├── Views/               Écrans (sous-dossiers Auth/, Launch/, Planning/), aiguillage, onglets, Components.swift
│   └── Resources/           Traductions fr/en/ar, images, icône
└── firestore.rules          Règles de sécurité Firestore (à publier dans la console)
```

Règles suivies dans le code :
- La vue qui **crée** un ViewModel utilise `@StateObject` ; une vue qui le **reçoit** utilise `@ObservedObject`.
- Les ViewModels sont `@MainActor` (ils modifient l'interface).
- Les ViewModels reçoivent leur Repository dans `init` (injection de dépendances, chapitre 6).
- Les erreurs ne sont jamais perdues : elles deviennent un message traduit (`LoadState.failed` + `ErrorStateView`).
- Les textes passent par `"clé".localized` (fichiers `Resources/<langue>.lproj/Localizable.strings`).

### Modèle de données Firestore

```
users/{uid}                      name, email                          ✅
users/{uid}/favorites/{mealId}   name, thumbnail, area                ✅
users/{uid}/planning/{jour}      mealId, name, thumbnail, area        ✅ (jour = monday … sunday)
users/{uid}/shopping/{id}        name, measure, done                  ✅
```

## Travailler sans Mac (depuis Windows)

Windows ne peut ni compiler ni lancer une app iOS : il faut Xcode, donc un Mac. L'organisation est :

1. **Écrire le code sur Windows** (VS Code), puis l'envoyer sur GitHub (`git push`).
2. **Compiler et tester sur le Mac de l'école** : récupérer le code (`git pull`), puis ⌘R dans Xcode.

Autres solutions pour avoir un Mac : un membre de l'équipe qui en possède un, ou un Mac loué dans le
cloud (MacinCloud, Scaleway, AWS EC2 Mac), payant. Les machines virtuelles macOS sur PC
(« Hackintosh ») sont déconseillées : contraires à la licence d'Apple et instables avec Xcode.

## Mise en place

### 1. Dépôt GitHub (déjà fait)

Le code est sur https://github.com/yassin0711/ios-projet. **Repassez-le en privé** dès que possible
(Settings → *Danger Zone* → *Change visibility*) : en public, une autre équipe pourrait le copier
(note de 0). Ajoutez les autres membres dans Settings → Collaborators.

### 2. Firebase (une seule fois, par un membre)

1. Sur https://console.firebase.google.com : créer un projet « Matbakhi ».
2. Ajouter une app iOS avec l'identifiant de bundle **`com.matbakhi.app`**. Les étapes « Ajouter le SDK »
   et « Ajouter le code d'initialisation » de l'assistant sont déjà faites dans le code : passez-les.
3. Authentication → Sign-in method : activer **E-mail/Mot de passe** et **Google**.
4. **Ensuite seulement**, télécharger `GoogleService-Info.plist` (⚙️ Paramètres du projet → Vos
   applications) et le placer dans `Matbakhi/Resources/`. S'il est téléchargé avant d'activer Google,
   il lui manque `REVERSED_CLIENT_ID` et la connexion Google ne fonctionne pas.
   Ce fichier est exclu de Git (`.gitignore`) : partagez-le avec l'équipe par un autre moyen.
5. Firestore Database → créer la base, puis onglet **Règles** : coller le contenu de
   [firestore.rules](firestore.rules) et **Publier** (chacun ne peut lire que ses propres données).

Sans ce fichier, l'app se lance directement sur l'accueil, sans écran de connexion (pratique pour
travailler sur les autres écrans).

### 3. Lancer l'app sur le Mac (Xcode 16 ou plus récent)

Le projet Xcode est **déjà prêt** dans le dépôt : SDK aux bonnes versions (Firebase 11,
Google Sign-In 8, Google Mobile Ads 12), identifiant de test des pubs, retour de la connexion
Google, bundle `com.matbakhi.app`, iOS 17. Il n'y a **aucun réglage** à faire.

1. Dans le Terminal :
   ```bash
   cd ~/Desktop
   rm -rf ios-projet          # seulement si un ancien dossier existe
   git clone https://github.com/yassin0711/ios-projet.git
   ```
2. Copier `GoogleService-Info.plist` dans `ios-projet/Matbakhi/Resources/` (clé USB, e-mail…).
3. Double-cliquer sur `ios-projet/Matbakhi.xcodeproj`, attendre la fin du téléchargement des SDK
   (barre en haut, quelques minutes), choisir un simulateur iPhone, puis **⌘R**.

Les fichiers ajoutés plus tard dans `Matbakhi/` apparaissent tout seuls dans Xcode.

**En cas d'erreur de paquets** (« could not be resolved ») : File → Packages → **Reset Package
Caches**. Si ça ne suffit pas, quitter Xcode puis :
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Matbakhi-* ~/Library/Caches/org.swift.swiftpm
```

**Vérification automatique** : à chaque `git push`, un Mac de GitHub compile l'app avec Xcode 16.2
(onglet *Actions* du dépôt). Une coche verte signifie que le code compile.

## Prochaines étapes

1. ~~Authentification : Connexion, Inscription, Mot de passe oublié, Google Sign-In.~~ ✅
2. ~~Firestore : profil, favoris, planning, liste de courses, formulaire « Ajouter un article ».~~ ✅
3. ~~Publicités : bannière sur l'accueil, interstitielle après quelques recettes consultées.~~ ✅
4. ~~Projet Xcode prêt à l'emploi, compilé avec succès sur GitHub (Xcode 16.2).~~ ✅
5. Tester l'app sur le Mac de l'école (voir « Mise en place », étape 3).
6. Bonus facultatif : vérifier en mode avion que favoris, planning et courses restent visibles.
