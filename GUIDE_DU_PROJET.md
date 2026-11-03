# Comprendre le projet Matbakhi

Guide pour les membres de l'équipe qui débutent en Swift. Il explique comment l'app est construite,
fichier par fichier, et relie chaque notion au cours (chapitres 1 à 6).

> Lisez-le avec le code ouvert à côté : les liens ouvrent directement les fichiers.
> Dans les extraits, certains commentaires ont été ajoutés pour l'explication.

## Sommaire

1. [L'app en bref](#1-lapp-en-bref)
2. [La grande idée : chaque fichier a un seul rôle](#2-la-grande-idée--chaque-fichier-a-un-seul-rôle)
3. [La carte des fichiers](#3-la-carte-des-fichiers)
4. [Les notions Swift utilisées](#4-les-notions-swift-utilisées)
5. [Ce qui se passe au lancement de l'app](#5-ce-qui-se-passe-au-lancement-de-lapp)
6. [Ce qui se passe quand on cherche « pasta »](#6-ce-qui-se-passe-quand-on-cherche--pasta-)
7. [Changer de thème ou de langue](#7-changer-de-thème-ou-de-langue)
8. [Firebase : connexion, favoris, planning et courses](#8-firebase--connexion-favoris-planning-et-courses)
9. [Les publicités (Google Mobile Ads)](#9-les-publicités-google-mobile-ads)
10. [Ajouter un nouvel écran : la marche à suivre](#10-ajouter-un-nouvel-écran--la-marche-à-suivre)
11. [Questions possibles à l'oral](#11-questions-possibles-à-loral)
12. [Glossaire](#12-glossaire)

---

## 1. L'app en bref

Matbakhi affiche des recettes qui viennent d'Internet (l'API gratuite TheMealDB). Pour l'instant,
l'utilisateur peut :

- voir une animation de lancement, puis une présentation en 3 pages (la première fois seulement) ;
- consulter l'accueil : recette du jour, catégories, recettes tunisiennes ;
- chercher une recette par son nom ;
- ouvrir une catégorie, puis une recette, pour voir les ingrédients et la préparation ;
- changer le thème (clair / sombre) et la langue (français / anglais / arabe) dans les Réglages ;
- se connecter (e-mail ou Google), créer un compte, recevoir un lien en cas de mot de passe oublié ;
- ajouter des recettes en favoris (❤️), enregistrés dans Firestore ;
- prévoir une recette pour un jour de la semaine (📅 planning) ;
- ajouter les ingrédients d'une recette à sa liste de courses (🛒) et les cocher en magasin ;
- ajouter un article à la main dans la liste de courses, grâce à un formulaire validé ;
- voir des publicités de test : une bannière sur l'accueil, une pub plein écran toutes les 3 recettes.


```
Splash → Présentation (1re fois) → Connexion ──→ Inscription / Mot de passe oublié
                                       │
                                       ▼ (une fois connecté)
                                    Onglets
                                     ├── Accueil ───→ Liste d'une catégorie ───→ Détail (❤️ 📅 🛒)
                                     ├── Recherche ─────────────────────────────→ Détail (❤️)
                                     ├── Favoris ───────────────────────────────→ Détail (❤️)
                                     ├── Planning ──→ Détail   ·   🛒 ──→ Liste de courses ──→ ＋ Ajouter un article
                                     └── Réglages (compte, déconnexion)
```

---

## 2. La grande idée : chaque fichier a un seul rôle

Si on met tout dans la vue (affichage, appel réseau, gestion des erreurs), le code devient vite
illisible. Le projet suit donc l'architecture **MVVM** (chapitre 3), complétée
par le pattern **Repository** (chapitre 5).

Pour retenir, pensez à un restaurant :

| Couche | Rôle | Au restaurant | Exemple |
|---|---|---|---|
| **View** (vue) | Affiche l'écran, transmet les actions de l'utilisateur | La salle : ce que voit le client | `SearchView` |
| **ViewModel** | Logique de l'écran et état (chargement, résultats, erreur) | Le serveur : prend la commande, revient avec le plat ou annonce un problème | `SearchViewModel` |
| **Repository** | Va chercher les données (ici sur Internet) | La cuisine : sait où trouver les ingrédients | `TheMealDBRepository` |
| **Model** | Décrit les données | Le plat | `Meal` |

```
SearchView ──demande──▶ SearchViewModel ──demande──▶ MealRepository ──HTTP──▶ API TheMealDB
    ▲                         │
    └──── se redessine ◀──────┘  (quand sa propriété @Published "state" change)
```

**Règle d'or : chaque couche ne parle qu'à sa voisine.** La vue ne fait jamais d'appel réseau,
et le Repository ne sait rien de l'affichage.

---

## 3. La carte des fichiers

Le projet suit l'organisation du cours (chapitre 3) : un dossier par couche. Un sous-dossier
regroupe plusieurs écrans liés ; un écran seul reste directement dans `Views/`.

```
Matbakhi/
├── MatbakhiApp.swift   Point d'entrée de l'app
├── Models/       Les données, les réglages (thème, langue), les états et la validation
├── Services/     L'accès aux données (API, Firebase) et les publicités
├── ViewModels/   Un ViewModel par écran qui charge des données de l'API
├── Views/        Les écrans : Auth/, Launch/, Planning/ et les autres, plus Components.swift
└── Resources/    Traductions, icône, fichier Firebase
```

### Le point d'entrée

| Fichier | Rôle | Cours |
|---|---|---|
| [MatbakhiApp.swift](Matbakhi/MatbakhiApp.swift) | Point d'entrée (`@main`). Démarre Firebase et les publicités, partage les services, applique le thème et la langue | ch. 2 |

### Models/ : les données et les types communs

| Fichier | Rôle | Cours |
|---|---|---|
| [AppSettings.swift](Matbakhi/Models/AppSettings.swift) | Enums `AppTheme` (thème) et `AppLanguage` (langue, sens de lecture), et `"clé".localized` qui traduit un texte | ch. 1 |
| [LoadState.swift](Matbakhi/Models/LoadState.swift) | Les 5 états possibles d'un écran qui charge des données | ch. 1, 5 |
| [Validation.swift](Matbakhi/Models/Validation.swift) | Règles des formulaires (nom, e-mail, mot de passe) | ch. 3 |
| [Meal.swift](Matbakhi/Models/Meal.swift) | Une recette et son décodage depuis le JSON de l'API | ch. 1, 5 |
| [MealCategory.swift](Matbakhi/Models/MealCategory.swift) | Une catégorie, et `MealListSource` (catégorie ou pays) | ch. 5 |

### Services/ : l'accès aux données

| Fichier | Rôle | Cours |
|---|---|---|
| [MealRepository.swift](Matbakhi/Services/MealRepository.swift) | Le protocole `MealRepository` et `TheMealDBRepository`, qui appelle l'API | ch. 5 |
| [AuthService.swift](Matbakhi/Services/AuthService.swift) | Connexion Firebase : e-mail, Google, inscription, mot de passe oublié. Contient aussi `userCollection("...")`, la collection Firestore de l'utilisateur connecté | ch. 5 |
| [FavoritesService.swift](Matbakhi/Services/FavoritesService.swift) | Favoris dans Cloud Firestore, mis à jour en temps réel | ch. 5 |
| [PlanningService.swift](Matbakhi/Services/PlanningService.swift) | Planning de la semaine dans Firestore, et l'enum `WeekDay` | ch. 5 |
| [ShoppingService.swift](Matbakhi/Services/ShoppingService.swift) | Liste de courses dans Firestore, et la struct `ShoppingItem` | ch. 5 |
| [Ads.swift](Matbakhi/Services/Ads.swift) | Tout sur les publicités : identifiants de test, bannière, pub plein écran | — |

### ViewModels/ : un par écran qui charge des données

| Fichier | Écran |
|---|---|
| [HomeViewModel.swift](Matbakhi/ViewModels/HomeViewModel.swift) | Accueil |
| [SearchViewModel.swift](Matbakhi/ViewModels/SearchViewModel.swift) | Recherche |
| [MealListViewModel.swift](Matbakhi/ViewModels/MealListViewModel.swift) | Liste d'une catégorie ou d'un pays |
| [MealDetailViewModel.swift](Matbakhi/ViewModels/MealDetailViewModel.swift) | Détail d'une recette |

Les écrans Favoris, Planning et Courses n'ont pas de ViewModel : ils lisent directement le service
Firestore partagé (`@EnvironmentObject`), qui joue déjà ce rôle.

### Views/ : les écrans

| Fichier | Rôle |
|---|---|
| [RootView.swift](Matbakhi/Views/RootView.swift) | Aiguillage : splash → présentation → connexion → onglets |
| [MainTabView.swift](Matbakhi/Views/MainTabView.swift) | Les onglets (`TabView`) et la navigation commune à tous les onglets |
| [Launch/SplashView.swift](Matbakhi/Views/Launch/SplashView.swift) | Animation de lancement |
| [Launch/OnboardingView.swift](Matbakhi/Views/Launch/OnboardingView.swift) | Présentation en 3 pages |
| [Auth/LoginView.swift](Matbakhi/Views/Auth/LoginView.swift) | Connexion (e-mail et Google) |
| [Auth/SignUpView.swift](Matbakhi/Views/Auth/SignUpView.swift) | Inscription |
| [Auth/ForgotPasswordView.swift](Matbakhi/Views/Auth/ForgotPasswordView.swift) | Mot de passe oublié |
| [HomeView.swift](Matbakhi/Views/HomeView.swift) | Accueil (+ bannière publicitaire) |
| [SearchView.swift](Matbakhi/Views/SearchView.swift) | Recherche |
| [MealListView.swift](Matbakhi/Views/MealListView.swift) | Recettes d'une catégorie ou d'un pays |
| [MealDetailView.swift](Matbakhi/Views/MealDetailView.swift) | Détail d'une recette + boutons ❤️, planning et courses |
| [FavoritesView.swift](Matbakhi/Views/FavoritesView.swift) | Mes favoris |
| [Planning/PlanningView.swift](Matbakhi/Views/Planning/PlanningView.swift) | Planning de la semaine |
| [Planning/ShoppingListView.swift](Matbakhi/Views/Planning/ShoppingListView.swift) | Liste de courses (cocher, supprimer), ouverte depuis le planning |
| [Planning/AddItemView.swift](Matbakhi/Views/Planning/AddItemView.swift) | Formulaire « Ajouter un article », affiché dans une feuille |
| [SettingsView.swift](Matbakhi/Views/SettingsView.swift) | Réglages : compte, thème, langue |
| [Components.swift](Matbakhi/Views/Components.swift) | Petites vues réutilisables : chargement, erreur, grille et carte de recette, image, champ de formulaire |

### Le reste

| Élément | Rôle |
|---|---|
| `Resources/fr.lproj`, `en.lproj`, `ar.lproj` | Les textes traduits (`Localizable.strings`) |
| `Resources/Assets.xcassets` | Icône de l'app et couleur principale (orange) |
| `Matbakhi.xcodeproj` | Projet Xcode prêt à l'emploi : SDK et réglages déjà faits |
| `Info.plist` | Identifiant de test des pubs et retour de la connexion Google |
| `.github/workflows/build.yml` | Compilation automatique sur un Mac de GitHub à chaque `git push` |
| [firestore.rules](firestore.rules) | Règles de sécurité Firestore, à publier dans la console Firebase |

---

## 4. Les notions Swift utilisées

### 4.1 `let` et `var` (chapitre 1)

- `let` : valeur fixée une fois pour toutes. Exemple : `private let repository: MealRepository`.
  Le ViewModel garde le même Repository toute sa vie.
- `var` : valeur qui peut changer. Exemple : `@Published var query = ""` change à chaque lettre tapée.

### 4.2 `struct` et `class` (chapitre 1)

```swift
struct Meal: Identifiable, Hashable {     // struct : type valeur, copié à l'affectation
    let id: String
    let name: String
    // ...
}

@MainActor
final class SearchViewModel: ObservableObject {   // class : type référence, partagé
    // ...
}
```

- Les **modèles** (`Meal`, `MealCategory`) sont des `struct` : ce sont de simples données.
- Les **ViewModels** sont des `class`, car `ObservableObject` l'exige. La vue et SwiftUI doivent
  partager le **même** objet pour voir ses changements.
- `final` signifie qu'aucune autre classe ne peut hériter de celle-ci.

### 4.3 Les optionnels (chapitre 1)

Un optionnel est une boîte qui peut être vide (`nil`). Exemple : `let thumbnailURL: URL?`
signifie qu'une recette peut ne pas avoir d'image.

| Outil | Exemple dans le projet | Explication |
|---|---|---|
| `if let` | `if let featured = home.featured { FeaturedMealCard(meal: featured) }` | Affiche la carte seulement s'il y a une recette du jour |
| `guard let` | `guard let url = components?.url else { throw NetworkError.invalidURL }` | Arrête tout si l'URL est invalide |
| `??` | `return response.meals ?? []` | L'API renvoie `null` quand il n'y a pas de résultat : on renvoie une liste vide |
| `?.` | `components?.url` | Lit `url` seulement si `components` n'est pas `nil` |

Le projet n'utilise **jamais** le `!` (force unwrap) : il fait planter l'app si la valeur est `nil`.

### 4.4 Les enums (chapitre 1)

**Enum simple**, dans [AppSettings.swift](Matbakhi/Models/AppSettings.swift) :

```swift
enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
}
```

- `: String` : chaque cas a une valeur texte (`"system"`, `"light"`…). C'est ce qui permet de le
  sauvegarder dans les réglages du téléphone.
- `CaseIterable` donne `AppTheme.allCases`, la liste de tous les cas, utilisée pour remplir le menu
  des Réglages.

**Enum avec valeurs associées**, dans [LoadState.swift](Matbakhi/Models/LoadState.swift). C'est
la pièce la plus importante du projet :

```swift
enum LoadState<Value> {
    case idle            // rien n'a encore été demandé
    case loading         // chargement en cours
    case loaded(Value)   // succès : contient les données
    case empty           // succès, mais rien à afficher
    case failed(Error)   // échec : contient l'erreur
}
```

Chaque vue fait un `switch` sur cet état :

```swift
switch viewModel.state {
case .idle:               ContentUnavailableView(...)   // message d'aide
case .loading:            LoadingStateView()            // indicateur de chargement
case .loaded(let meals):  MealGrid(meals: meals)        // grille de recettes
case .empty:              ContentUnavailableView(...)   // « Aucun résultat »
case .failed(let error):  ErrorStateView(error: error) { ... }
}
```

Swift oblige à traiter **tous** les cas : impossible d'oublier l'état d'erreur ou l'état vide.
C'est exactement ce que demande le sujet (« indicateur de chargement, messages d'erreur, états vides »).

`<Value>` rend l'enum **générique** : elle sert pour une liste (`LoadState<[Meal]>`) comme pour
une seule recette (`LoadState<Meal>`).

### 4.5 Les protocoles (chapitre 1, puis 5 et 6)

Un protocole est un contrat : il dit **quoi** faire, pas **comment**.

```swift
protocol MealRepository {
    func searchMeals(query: String) async throws -> [Meal]
    func mealDetail(id: String) async throws -> Meal?
    // ...
}
```

`TheMealDBRepository` respecte ce contrat en appelant la vraie API. Le ViewModel ne connaît que le
protocole : on pourrait lui donner une autre implémentation (par exemple une fausse version qui
renvoie des données fixes) sans changer une ligne du ViewModel.

Le projet utilise aussi des protocoles fournis par Apple :

| Protocole | Pourquoi |
|---|---|
| `Identifiable` | `ForEach` et `List` ont besoin d'un `id` unique par élément |
| `Hashable` | Nécessaire pour la navigation par valeur (`NavigationLink(value:)`) |
| `Decodable` | Permet de créer l'objet à partir du JSON |
| `ObservableObject` | Permet à la vue d'observer le ViewModel |

### 4.6 Les extensions (chapitre 1)

Une extension ajoute des fonctionnalités à un type qui existe déjà, même un type d'Apple :

```swift
extension String {
    var localized: String { ... }   // voir AppSettings.swift
}
```

Grâce à elle, `"tab.home".localized` renvoie « Accueil », « Home » ou « الرئيسية ».

Autres exemples : `extension Meal: Decodable` sépare le décodage du modèle, et
`extension View { func mealNavigationDestinations() }` crée un modificateur réutilisable.

### 4.7 Les closures (chapitre 1)

Une closure est du code emballé qu'on transporte pour l'exécuter plus tard.

**Prévenir quand quelque chose est fini.** `SplashView` ne décide pas de la suite : elle appelle
`onFinish()` à la fin de son animation, et c'est `RootView` qui choisit quoi afficher.

```swift
SplashView {                                    // cette closure est "onFinish"
    withAnimation(.easeInOut(duration: 0.4)) { showSplash = false }
}
```

**Transformer des listes**, dans [Meal.swift](Matbakhi/Models/Meal.swift) :

```swift
tags = text("strTags")?                                 // "Meat, Casserole"
    .split(separator: ",")                              // ["Meat", " Casserole"]
    .map { $0.trimmingCharacters(in: .whitespaces) }    // ["Meat", "Casserole"]
    ?? []                                               // [] si la recette n'a pas de tags
```

`$0` désigne le premier paramètre de la closure, ici chaque élément de la liste.

### 4.8 `async` / `await` et `Task` (chapitres 1 et 5)

Un appel réseau prend du temps. Une fonction `async` peut se mettre en pause, et `await` marque
l'endroit où on attend. Pendant ce temps, l'app ne se fige pas.

```swift
let meals = try await repository.searchMeals(query: text)
```

Les différentes façons de lancer du code `async` :

| Écriture | Quand l'utiliser | Exemple |
|---|---|---|
| `Task { ... }` | Depuis du code normal (un bouton) | Bouton « Réessayer » : `Task { await viewModel.load() }` |
| `.task { ... }` | Quand l'écran apparaît (annulé s'il disparaît) | `HomeView` charge l'accueil |

Dans `HomeViewModel`, les 3 appels se font l'un après l'autre, chacun avec `await` :

```swift
let featured = try await repository.randomMeal()
let categories = try await repository.categories()
let tunisianMeals = try await repository.meals(from: .area("Tunisian"))
```

### 4.9 Les erreurs : `throw`, `try`, `do` / `catch` (chapitre 5)

Le Repository **lance** (`throw`) une erreur précise, et le ViewModel l'**attrape** (`catch`) pour
la transformer en message :

```swift
do {
    let meals = try await repository.searchMeals(query: text)
    state = meals.isEmpty ? .empty : .loaded(meals)
} catch {
    // Écran quitté pendant le chargement (tâche annulée) : on rechargera au retour
    state = Task.isCancelled ? .idle : .failed(error)
}
```

- `condition ? a : b` est l'opérateur ternaire : `a` si la condition est vraie, sinon `b`.
- Quand on quitte un écran pendant le chargement, SwiftUI **annule** sa tâche (`Task.isCancelled`).
  Ce n'est pas une vraie erreur : on remet l'état à `.idle` pour que le chargement reprenne au retour.
- Les erreurs possibles sont listées dans l'enum `NetworkError` : `invalidURL`, `noConnection`,
  `server` et `decoding`. Chacune a un `messageKey`, la clé de son message traduit.
- `ErrorStateView` transforme l'erreur en message : `(error as? NetworkError)?.messageKey ?? "error.unknown"`
  veut dire « si c'est une `NetworkError`, son message ; sinon, le message *erreur inattendue* ».
- Le Repository vérifie aussi le **code de statut HTTP** : 200 = succès, 404 ou 500 = erreur.
- Dans le Repository, chaque `try?` est suivi d'un `throw` précis
  (`guard let ... = try? ... else { throw NetworkError.noConnection }`) : l'erreur n'est jamais
  perdue, elle devient un message clair.

### 4.10 `Codable` : du JSON vers Swift (chapitre 5)

L'API renvoie du texte au format JSON. `JSONDecoder` le transforme en objets Swift.

**Cas simple avec `CodingKeys`**, dans [MealCategory.swift](Matbakhi/Models/MealCategory.swift).
Les noms du JSON (`strCategory`) ne sont pas ceux qu'on veut en Swift (`name`), alors on fait le lien :

```swift
enum CodingKeys: String, CodingKey {
    case id = "idCategory"
    case name = "strCategory"
    case thumbnailURL = "strCategoryThumb"
}
```

**Cas avancé avec un décodage personnalisé**, dans [Meal.swift](Matbakhi/Models/Meal.swift).
L'API envoie les ingrédients dans 20 champs séparés, souvent vides :

```json
{ "strIngredient1": "soy sauce", "strMeasure1": "3/4 cup",
  "strIngredient2": "water",     "strMeasure2": "1/2 cup",
  "strIngredient3": " ",         "strIngredient4": null, ... }
```

Le code `init(from decoder:)` parcourt les champs 1 à 20, ignore ceux qui sont vides et construit
un vrai tableau :

```swift
ingredients = [Ingredient(id: 1, name: "soy sauce", measure: "3/4 cup"),
               Ingredient(id: 2, name: "water", measure: "1/2 cup")]
```

### 4.11 Les mots qui commencent par `@` (chapitres 2 et 3)

| Mot-clé | Où | Rôle | Exemple dans le projet |
|---|---|---|---|
| `@main` | struct | Point d'entrée de l'app | `MatbakhiApp` |
| `@State` | Vue | Petite donnée locale à la vue | `@State private var showSplash = true` |
| `@StateObject` | Vue | La vue **crée** et garde un ViewModel | `@StateObject private var viewModel = HomeViewModel()` |
| `@ObservedObject` | Vue | La vue **reçoit** un ViewModel créé ailleurs | (pas encore utilisé) |
| `@EnvironmentObject` | Vue | Objet **partagé** par toute l'app, injecté une seule fois | `AuthService`, `FavoritesService`, `PlanningService` |
| `@Published` | ViewModel | La vue se redessine quand la valeur change | `@Published private(set) var state` |
| `@AppStorage` | Vue | Valeur sauvegardée sur le téléphone, qui survit à la fermeture | Thème, langue, présentation déjà vue |
| `@SceneStorage` | Vue | Mémorise l'onglet sélectionné | `MainTabView` |
| `@MainActor` | Classe | Le code s'exécute sur le fil principal, obligatoire pour modifier l'écran | Tous les ViewModels |
| `$` (préfixe) | — | Crée un **binding** : un lien dans les deux sens | `.searchable(text: $viewModel.query)` |

Deux points importants :

- **`@StateObject` plutôt que `@ObservedObject`** quand la vue crée le ViewModel. Avec
  `@ObservedObject`, le ViewModel serait recréé à chaque fois que SwiftUI redessine la vue, et les
  données seraient perdues. Le cours ne mentionne pas `@StateObject`, mais c'est la règle d'Apple.
- **`private(set)`** : la vue peut **lire** `state`, mais seul le ViewModel peut le **modifier**.

---

## 5. Ce qui se passe au lancement de l'app

1. iOS lance `MatbakhiApp`, la struct marquée `@main`. Son `init()` configure Firebase, si le
   fichier `GoogleService-Info.plist` est présent, et démarre le SDK des publicités.
2. `MatbakhiApp` crée les services partagés (`AuthService`, `FavoritesService`, `PlanningService`,
   `ShoppingService`), les partage avec `.environmentObject(...)`,
   et affiche `RootView` en lui appliquant le thème (`.preferredColorScheme`), la langue
   (`.environment(\.locale, ...)`) et le sens de lecture (`.environment(\.layoutDirection, ...)`).
3. `RootView` commence par `SplashView`, car `showSplash` vaut `true`. Le `.task` du splash lance
   l'animation (le logo tourne et grossit), attend 1,6 seconde puis appelle `onFinish`.
4. `onFinish` met `showSplash` à `false`. SwiftUI recalcule `RootView` :
   - si la présentation n'a jamais été vue, il affiche `OnboardingView` ;
   - sinon, si personne n'est connecté, il affiche `LoginView` ;
   - sinon, il affiche `MainTabView`.
5. Dans la présentation, « Commencer » met `onboardingDone` à `true`. Grâce à `@AppStorage`,
   c'est sauvegardé : aux lancements suivants, la présentation ne revient pas.
6. `MainTabView` affiche `HomeView`, dont le `.task` appelle `viewModel.load()`. L'indicateur de
   chargement s'affiche, puis le contenu.

---

## 6. Ce qui se passe quand on cherche « pasta »

1. **L'utilisateur tape.** `.searchable(text: $viewModel.query)` écrit chaque lettre dans
   `viewModel.query`, grâce au binding `$`.
2. **Il appuie sur « Rechercher » au clavier.** `.onSubmit(of: .search)` lance
   `viewModel.search()` dans une `Task`.
3. **Le ViewModel vérifie le texte** ([SearchViewModel.swift](Matbakhi/ViewModels/SearchViewModel.swift)) :
   si le champ est vide, il ne fait rien.
4. **Le chargement s'affiche.** `state = .loading`. Comme `state` est `@Published`, `SearchView` se
   redessine et affiche `LoadingStateView`.
5. **Le Repository appelle l'API** ([MealRepository.swift](Matbakhi/Services/MealRepository.swift)) :
   - il construit l'URL `https://www.themealdb.com/api/json/v1/1/search.php?s=pasta` ;
   - il envoie la requête avec `URLSession.shared.data(from:)` ;
   - il vérifie que le code HTTP vaut 200 (succès) ;
   - il décode le JSON en `MealsResponse` et renvoie `response.meals ?? []`.
6. **Le ViewModel met à jour l'état** : `.loaded(meals)`, `.empty` s'il n'y a aucun résultat, ou
   `.failed(NetworkError.noConnection)` sans Internet.
7. **La vue se redessine** et affiche, selon l'état :
   - la grille de cartes ;
   - « Aucune recette ne correspond à votre recherche » ;
   - le message d'erreur avec un bouton « Réessayer ».
8. **L'utilisateur touche une carte.** `NavigationLink(value: meal)` demande au `NavigationStack`
   d'afficher la destination prévue pour un `Meal`, définie par `mealNavigationDestinations()` dans
   [MainTabView.swift](Matbakhi/Views/MainTabView.swift) : c'est `MealDetailView`.
   - Une recette issue de la recherche est complète : elle s'affiche tout de suite.
   - Une recette venant d'une catégorie est partielle (nom et image seulement) :
     `MealDetailViewModel` charge d'abord le détail avec `lookup.php`.

---

## 7. Changer de thème ou de langue

### Le thème

1. Dans `SettingsView`, le menu est relié à `@AppStorage("app.theme")`. Le choix est sauvegardé
   sur le téléphone.
2. `MatbakhiApp` lit la même clé et applique `.preferredColorScheme(theme.colorScheme)` :
   `.light`, `.dark`, ou `nil` pour suivre le réglage du téléphone.

### La langue

1. Le menu des Réglages est relié à `@AppStorage("app.language")`.
2. Tous les textes passent par `.localized`. Par exemple, `"settings.title".localized` ouvre le
   dossier de la langue choisie (`ar.lproj`) et lit la clé dans `Localizable.strings` :
   ```
   "settings.title" = "الإعدادات";
   ```
3. Dans `RootView`, `MainTabView().id(language)` fait que, quand la langue change, SwiftUI
   considère que c'est une **nouvelle** vue. Il reconstruit tout l'écran, et tous les textes sont
   retraduits. `@SceneStorage` garde l'onglet Réglages sélectionné.
4. Pour l'arabe, `.environment(\.layoutDirection, .rightToLeft)` inverse automatiquement toute la
   mise en page.

À savoir :
- **Pour ajouter un texte**, ajoutez la même clé dans les **trois** fichiers `Localizable.strings`.
- **Le contenu des recettes reste en anglais** : l'API TheMealDB n'existe qu'en anglais. L'écran de
  détail le signale.

---

## 8. Firebase : connexion, favoris, planning et courses

### Qui fait quoi

| Fichier | Rôle |
|---|---|
| `AuthService` | Toutes les opérations de connexion : se connecter, créer un compte, mot de passe oublié, Google, se déconnecter |
| `FavoritesService` | Lire, ajouter et retirer des favoris dans Firestore |
| `PlanningService` | Lire, prévoir et retirer les recettes de la semaine |
| `ShoppingService` | Lire, ajouter, cocher et supprimer les articles de la liste de courses |
| `Validation` | Vérifier les champs des formulaires **avant** d'appeler Firebase |
| `FormField` | Un champ de saisie avec son message d'erreur en rouge |

Ces services sont créés **une seule fois**, dans `MatbakhiApp` (`@StateObject`), puis partagés
avec toutes les vues grâce à `.environmentObject(...)`. Une vue les récupère avec
`@EnvironmentObject` (chapitre 3) :

```swift
@EnvironmentObject private var auth: AuthService
```

### Comment l'app sait si quelqu'un est connecté

```swift
// AuthService : Firebase appelle ce code à chaque connexion et déconnexion
listener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
    self?.user = user
}
```

Comme `user` est `@Published`, `RootView` se redessine aussitôt :

```swift
} else if auth.isFirebaseConfigured && auth.user == nil {
    LoginView()      // personne n'est connecté
} else {
    MainTabView()    // l'app
}
```

Les écrans de connexion n'ont donc **jamais besoin de naviguer** après une connexion réussie :
il suffit que Firebase change `user`. Sans le fichier `GoogleService-Info.plist`,
`isFirebaseConfigured` vaut `false` et l'app s'ouvre directement sur l'accueil.

### Un formulaire, étape par étape (LoginView)

1. Les champs sont des `@State` (`email`, `password`), reliés aux `FormField` par `$email`.
2. Au toucher de « Se connecter », `showErrors` passe à `true` : chaque champ affiche son erreur
   éventuelle, calculée par `Validation`. Par exemple, `Validation.email("ali.mail.com")` renvoie
   `"validation.email"`, la clé du message « Adresse e-mail invalide ».
3. S'il reste une erreur, `guard` arrête tout : Firebase n'est pas appelé.
4. Sinon, `isLoading` passe à `true` (indicateur de chargement, boutons désactivés) et on appelle
   `auth.signIn(...)`.
5. Si Firebase refuse (mauvais mot de passe, e-mail déjà utilisé…), `AuthService.messageKey(for:)`
   transforme l'erreur en message clair et traduit.

### La connexion avec Google

1. `GIDSignIn` ouvre la fenêtre de connexion Google.
2. Google renvoie un jeton (`idToken`) qui prouve l'identité de l'utilisateur.
3. On donne ce jeton à Firebase (`GoogleAuthProvider.credential`), qui connecte l'utilisateur.
4. `.onOpenURL`, dans `MatbakhiApp`, gère le retour dans l'app. Il faut pour cela ajouter
   `REVERSED_CLIENT_ID` dans les *URL Types* de l'onglet Info d'Xcode (voir README).

### Les données dans Firestore

```
users/{uid}                         { name, email }                    ← profil, créé à l'inscription
users/{uid}/favorites/{idRecette}   { name, thumbnail, area }          ← un document par favori
users/{uid}/planning/{jour}         { mealId, name, thumbnail, area }  ← jour = monday … sunday
users/{uid}/shopping/{idArticle}    { name, measure, done }            ← un document par ingrédient
```

Les trois services suivent **le même modèle** : `startListening()` écoute la collection, et de
petites fonctions écrivent dedans. `userCollection("favorites")` donne la collection de
l'utilisateur connecté (ou `nil` si personne n'est connecté).

- Toucher ❤️ appelle `FavoritesService.toggle(meal)`, qui crée ou supprime le document.
- Le menu 📅 du détail appelle `PlanningService.plan(meal, on: day)`. Le jour sert d'identifiant du
  document : prévoir une autre recette le même jour **remplace** l'ancienne (`setData`).
- « Ajouter aux courses » appelle `ShoppingService.add(ingredients)` : un document par ingrédient,
  avec un identifiant automatique (`addDocument`). Cocher un article appelle
  `updateData(["done": ...])`, qui ne modifie que ce champ.
- Le formulaire « Ajouter un article » ([AddItemView.swift](Matbakhi/Views/Planning/AddItemView.swift))
  suit le même modèle que la connexion : `showErrors` → `Validation.name` → `guard` → puis
  `ShoppingService.addItem(...)` et `dismiss()`, qui ferme la feuille.
- `addSnapshotListener` **écoute** la collection : à chaque changement, même depuis un autre
  téléphone, `favorites` est mis à jour. L'écran Favoris et le cœur se redessinent tout seuls.
- **Sécurité** : les règles de [firestore.rules](firestore.rules) n'autorisent chaque utilisateur
  qu'à lire et écrire sous `users/{son uid}`.

---

## 9. Les publicités (Google Mobile Ads)

Le sujet impose une bannière et une interstitielle, **avec les identifiants de test fournis par
Google**. Tout est dans un seul fichier : [Ads.swift](Matbakhi/Services/Ads.swift). Les pubs
affichées portent la mention « Test Ad ».

| Type | Où | Fichier |
|---|---|---|
| Bannière (320 × 50) | En bas de l'accueil | `BannerAdView` |
| Interstitielle (plein écran) | Toutes les 3 recettes ouvertes | `InterstitialAdService` |

- `MatbakhiApp` démarre le SDK une seule fois, au lancement (`MobileAds.shared.start`).
- `BannerView` est une vue **UIKit**. `UIViewRepresentable` permet de l'afficher dans SwiftUI :
  `makeUIView` crée la bannière et lance son chargement (`load(Request())`).
- Le `.task` du détail appelle `InterstitialAdService.shared.mealOpened()`. Ce service compte les
  recettes ouvertes : à la 3e, la 6e…, il affiche la pub déjà chargée, puis en charge une nouvelle à
  l'avance. Une interstitielle ne peut s'afficher **qu'une seule fois**.
- L'identifiant **d'application** de test (`GADApplicationIdentifier`) se règle dans l'onglet Info
  d'Xcode (voir README) : sans lui, l'app plante au lancement.

---

## 10. Ajouter un nouvel écran : la marche à suivre

Exemple : imaginons un nouvel écran « Communauté » (recettes publiées). Suivez toujours le même ordre.

1. **Model** (si nouvelles données) dans `Models/`, par exemple `struct Recipe: Identifiable`.
2. **Repository** dans `Services/` : un protocole, plus une implémentation (Firestore).
3. **ViewModel** dans `ViewModels/`, sur ce modèle :

   ```swift
   @MainActor
   final class CommunityViewModel: ObservableObject {
       @Published private(set) var state: LoadState<[Recipe]> = .idle
       private let repository: RecipeRepository

       init(repository: RecipeRepository = FirestoreRecipeRepository()) {
           self.repository = repository
       }

       func load() async {
           state = .loading
           do {
               let recipes = try await repository.recipes()
               state = recipes.isEmpty ? .empty : .loaded(recipes)
           } catch {
               state = Task.isCancelled ? .idle : .failed(error)
           }
       }
   }
   ```

4. **Vue** dans `Views/` : `@StateObject private var viewModel = CommunityViewModel()`, puis un
   `switch viewModel.state` qui traite les 5 cas, avec `LoadingStateView`, `ErrorStateView` et
   `ContentUnavailableView`.
5. **Navigation** : ajoutez un onglet dans `MainTabView`, ou un `NavigationLink`.
6. **Textes** : ajoutez les clés dans les 3 fichiers `Localizable.strings`.
7. **Envoyez le code** (`git push`) : la coche verte de l'onglet *Actions* sur GitHub confirme
   qu'il compile. Puis, sur le Mac, `git pull` et ⌘R pour le tester.

---

## 11. Questions possibles à l'oral

**Pourquoi l'architecture MVVM ?**
Chaque fichier a un seul rôle : la vue affiche, le ViewModel gère la logique, le Repository va
chercher les données. Le code est plus lisible et plus facile à modifier.

**Quelle différence entre `@StateObject` et `@ObservedObject` ?**
`@StateObject` : la vue crée le ViewModel et le garde en vie. `@ObservedObject` : la vue reçoit un
ViewModel créé ailleurs. Avec `@ObservedObject` à la place de `@StateObject`, le ViewModel serait
recréé à chaque rafraîchissement.

**Pourquoi `Meal` est une `struct` et les ViewModels des `class` ?**
`Meal` est une simple donnée, copiée sans risque. Un ViewModel doit être **partagé** entre la vue et
SwiftUI pour que les changements soient vus, et `ObservableObject` exige une `class`.

**À quoi sert le protocole `MealRepository` ?**
Le ViewModel dépend du contrat, pas de l'API. Il reçoit son Repository dans `init` : c'est
l'injection de dépendances. On peut ainsi changer la source des données sans toucher au ViewModel.

**Comment gérez-vous les erreurs réseau ?**
Le Repository lance une `NetworkError` précise : pas de connexion, erreur serveur ou JSON invalide.
Le ViewModel l'attrape avec `do` / `catch` et passe à l'état `.failed`. La vue affiche alors un
message traduit avec un bouton « Réessayer ».

**Que se passe-t-il si l'API renvoie `"meals": null` ?**
La propriété `meals` est optionnelle (`[Meal]?`). Avec `?? []`, on obtient une liste vide, et
l'écran affiche l'état vide.

**Pourquoi `async` / `await` ?**
Pour que l'app ne se fige pas pendant l'attente de la réponse du serveur.

**Comment fonctionne la connexion ?**
`AuthService` utilise Firebase Authentication. Un écouteur (`addStateDidChangeListener`) met à jour
`user`, qui est `@Published`. `RootView` affiche l'écran de connexion tant que `user` vaut `nil`.

**Comment validez-vous les formulaires ?**
Avant d'appeler Firebase, chaque champ est vérifié par `Validation`, qui renvoie la clé d'un message
d'erreur traduit. Le message s'affiche en rouge sous le champ, et Firebase n'est appelé que si tout
est valide. Les erreurs renvoyées par Firebase sont aussi traduites en messages clairs.

**Comment les favoris sont-ils synchronisés ?**
Chaque favori est un document Firestore dans `users/{uid}/favorites`. `addSnapshotListener` prévient
l'app à chaque changement, en temps réel.

**Pourquoi des identifiants de test pour les publicités ?**
Le sujet l'exige, et Google l'impose pendant le développement : cliquer sur ses propres vraies pubs
peut faire bloquer le compte AdMob. Les pubs de test s'affichent normalement, avec la mention
« Test Ad ».

**Comment protégez-vous les données des utilisateurs ?**
Avec les règles de sécurité Firestore : un utilisateur connecté ne peut lire et écrire que ses
propres documents (`request.auth.uid == userId`).

**Pourquoi `@MainActor` sur les ViewModels ?**
Ils modifient des propriétés affichées à l'écran, et l'interface ne doit être modifiée que depuis le
fil principal.

**Comment fonctionne le changement de langue ?**
Les textes sont dans un fichier `Localizable.strings` par langue. La langue choisie est sauvegardée
avec `@AppStorage`, et `.id(language)` reconstruit l'interface pour retraduire tous les textes.
Pour l'arabe, la mise en page est inversée avec `layoutDirection`.

---

## 12. Glossaire

| Terme | Signification |
|---|---|
| **API** | Service sur Internet que l'app interroge pour obtenir des données |
| **REST / endpoint** | Une API REST expose des adresses (endpoints), comme `search.php`, appelées en HTTP |
| **JSON** | Format texte des données renvoyées par l'API |
| **Code de statut HTTP** | Nombre renvoyé par le serveur : 200 = succès, 404 = introuvable, 500 = erreur serveur |
| **Binding (`$`)** | Lien dans les deux sens entre une donnée et un contrôle (champ de texte, interrupteur…) |
| **Modificateur** | Fonction appliquée à une vue (`.padding()`, `.font()`…) qui renvoie une nouvelle vue |
| **NavigationStack** | Pile d'écrans : on « pousse » un écran par-dessus, le bouton retour l'enlève |
| **Injection de dépendances** | Donner à un objet ce dont il a besoin (son Repository) au lieu qu'il le crée lui-même |
| **RTL** | *Right-to-left* : écriture de droite à gauche, comme l'arabe |
| **UserDefaults** | Petit espace de stockage du téléphone pour les réglages (utilisé par `@AppStorage`) |
| **SDK** | Bibliothèque fournie par une entreprise (Firebase, Google Mobile Ads) |
| **Interstitielle** | Publicité plein écran, affichée entre deux écrans |
| **UIViewRepresentable** | Protocole qui permet d'afficher une vue UIKit dans SwiftUI |
| **Firebase Authentication** | Service de Google qui gère les comptes (inscription, connexion) |
| **Cloud Firestore** | Base de données de Firebase, organisée en collections et documents |
| **Listener (écouteur)** | Code appelé automatiquement à chaque changement (connexion, données Firestore) |
| **SPM** | *Swift Package Manager* : télécharge et intègre les SDK dans le projet |
