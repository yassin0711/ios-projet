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
8. [La connexion et les favoris (Firebase)](#8-la-connexion-et-les-favoris-firebase)
9. [Ajouter un nouvel écran : la marche à suivre](#9-ajouter-un-nouvel-écran--la-marche-à-suivre)
10. [Questions possibles à l'oral](#10-questions-possibles-à-loral)
11. [Glossaire](#11-glossaire)

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
- ajouter des recettes en favoris (❤️), enregistrés dans Firestore.

Le planning, la liste de courses et la communauté viendront ensuite.

```
Splash → Présentation (1re fois) → Connexion ──→ Inscription / Mot de passe oublié
                                       │
                                       ▼ (une fois connecté)
                                    Onglets
                                     ├── Accueil ───→ Liste d'une catégorie ───→ Détail (❤️)
                                     ├── Recherche ─────────────────────────────→ Détail (❤️)
                                     ├── Favoris ───────────────────────────────→ Détail (❤️)
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

### App/ : démarrage et structure générale

| Fichier | Rôle | Cours |
|---|---|---|
| [MatbakhiApp.swift](Matbakhi/App/MatbakhiApp.swift) | Point d'entrée (`@main`). Applique le thème et la langue à toute l'app | ch. 2 |
| [AppDelegate.swift](Matbakhi/App/AppDelegate.swift) | Démarre Firebase et les publicités au lancement | ch. 5 |
| [RootView.swift](Matbakhi/App/RootView.swift) | Aiguillage : splash → présentation → onglets | ch. 2, 3 |
| [MainTabView.swift](Matbakhi/App/MainTabView.swift) | Les onglets en bas de l'écran (`TabView`) | ch. 3 |

### Core/ : outils utilisés partout

| Fichier | Rôle | Cours |
|---|---|---|
| [AppSettings.swift](Matbakhi/Core/AppSettings.swift) | Enums `AppTheme` (thème) et `AppLanguage` (langue, sens de lecture) | ch. 1 |
| [Localization.swift](Matbakhi/Core/Localization.swift) | `"clé".localized` : traduit un texte dans la langue choisie | — |
| [LoadState.swift](Matbakhi/Core/LoadState.swift) | Les 5 états possibles d'un écran qui charge des données | ch. 1, 5 |
| [Validation.swift](Matbakhi/Core/Validation.swift) | Règles des formulaires (nom, e-mail, mot de passe) | ch. 3 |

### Models/ : les données

| Fichier | Rôle | Cours |
|---|---|---|
| [Meal.swift](Matbakhi/Models/Meal.swift) | Une recette et son décodage depuis le JSON de l'API | ch. 1, 5 |
| [MealCategory.swift](Matbakhi/Models/MealCategory.swift) | Une catégorie, et `MealListSource` (catégorie ou pays) | ch. 5 |

### Services/ : l'accès aux données

| Fichier | Rôle | Cours |
|---|---|---|
| [MealRepository.swift](Matbakhi/Services/MealRepository.swift) | Le protocole `MealRepository` et `TheMealDBRepository`, qui appelle l'API | ch. 5 |
| [AuthService.swift](Matbakhi/Services/AuthService.swift) | Connexion Firebase : e-mail, Google, inscription, mot de passe oublié | ch. 5 |
| [FavoritesService.swift](Matbakhi/Services/FavoritesService.swift) | Favoris dans Cloud Firestore, mis à jour en temps réel | ch. 5 |

### ViewModels/ : un par écran

| Fichier | Écran |
|---|---|
| [HomeViewModel.swift](Matbakhi/ViewModels/HomeViewModel.swift) | Accueil |
| [SearchViewModel.swift](Matbakhi/ViewModels/SearchViewModel.swift) | Recherche |
| [MealListViewModel.swift](Matbakhi/ViewModels/MealListViewModel.swift) | Liste d'une catégorie ou d'un pays |
| [MealDetailViewModel.swift](Matbakhi/ViewModels/MealDetailViewModel.swift) | Détail d'une recette |

### Views/ : les écrans

| Fichier | Rôle |
|---|---|
| [Launch/SplashView.swift](Matbakhi/Views/Launch/SplashView.swift) | Animation de lancement |
| [Launch/OnboardingView.swift](Matbakhi/Views/Launch/OnboardingView.swift) | Présentation en 3 pages |
| [Auth/LoginView.swift](Matbakhi/Views/Auth/LoginView.swift) | Connexion (e-mail et Google) |
| [Auth/SignUpView.swift](Matbakhi/Views/Auth/SignUpView.swift) | Inscription |
| [Auth/ForgotPasswordView.swift](Matbakhi/Views/Auth/ForgotPasswordView.swift) | Mot de passe oublié |
| [Home/HomeView.swift](Matbakhi/Views/Home/HomeView.swift) | Accueil |
| [Search/SearchView.swift](Matbakhi/Views/Search/SearchView.swift) | Recherche |
| [MealList/MealListView.swift](Matbakhi/Views/MealList/MealListView.swift) | Grille de recettes |
| [Detail/MealDetailView.swift](Matbakhi/Views/Detail/MealDetailView.swift) | Détail d'une recette + bouton ❤️ |
| [Favorites/FavoritesView.swift](Matbakhi/Views/Favorites/FavoritesView.swift) | Mes favoris |
| [Settings/SettingsView.swift](Matbakhi/Views/Settings/SettingsView.swift) | Réglages : compte, thème, langue |

### Views/Components/ : morceaux réutilisables

| Fichier | Rôle |
|---|---|
| [StateViews.swift](Matbakhi/Views/Components/StateViews.swift) | Vues « chargement », « erreur » et « vide » |
| [RemoteImage.swift](Matbakhi/Views/Components/RemoteImage.swift) | Image téléchargée avec apparition en fondu |
| [MealCard.swift](Matbakhi/Views/Components/MealCard.swift) | Carte d'une recette + animation au toucher |
| [NavigationDestinations.swift](Matbakhi/Views/Components/NavigationDestinations.swift) | Où mène un clic sur une recette ou une catégorie |
| [FormField.swift](Matbakhi/Views/Components/FormField.swift) | Champ de formulaire avec son message d'erreur |

### Le reste

| Élément | Rôle |
|---|---|
| `Resources/fr.lproj`, `en.lproj`, `ar.lproj` | Les textes traduits (`Localizable.strings`) |
| `Resources/Assets.xcassets` | Icône de l'app et couleur principale (orange) |
| `Matbakhi.xcodeproj` | Projet Xcode, à créer une fois sur le Mac (voir README) |
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

**Enum simple**, dans [AppSettings.swift](Matbakhi/Core/AppSettings.swift) :

```swift
enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
}
```

- `: String` : chaque cas a une valeur texte (`"system"`, `"light"`…). C'est ce qui permet de le
  sauvegarder dans les réglages du téléphone.
- `CaseIterable` donne `AppTheme.allCases`, la liste de tous les cas, utilisée pour remplir le menu
  des Réglages.

**Enum avec valeurs associées**, dans [LoadState.swift](Matbakhi/Core/LoadState.swift). C'est
la pièce la plus importante du projet :

```swift
enum LoadState<Value> {
    case idle            // rien n'a encore été demandé
    case loading         // chargement en cours
    case loaded(Value)   // succès : contient les données
    case empty           // succès, mais rien à afficher
    case failed(String)  // échec : contient la clé du message d'erreur
}
```

Chaque vue fait un `switch` sur cet état :

```swift
switch viewModel.state {
case .idle:                     EmptyStateView(...)        // message d'aide
case .loading:                  LoadingStateView()         // indicateur de chargement
case .loaded(let meals):        /* grille de recettes */
case .empty:                    EmptyStateView(...)        // « Aucun résultat »
case .failed(let messageKey):   ErrorStateView(messageKey: messageKey) { ... }
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
    var localized: String { L10n.string(self) }
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
} catch is CancellationError {
    state = .idle       // écran quitté pendant le chargement : on rechargera au retour
} catch {
    state = .failed((error as? NetworkError)?.messageKey ?? "error.unknown")
}
```

- `condition ? a : b` est l'opérateur ternaire : `a` si la condition est vraie, sinon `b`.
- `(error as? NetworkError)?.messageKey ?? "error.unknown"` signifie : si c'est une `NetworkError`,
  prendre son message (ex. : `"error.network.offline"`), sinon le message « erreur inattendue ».
- Les erreurs possibles sont listées dans l'enum `NetworkError` : `invalidURL`, `noConnection`,
  `server` et `decoding`.
- `CancellationError` n'est pas une vraie erreur : SwiftUI annule le chargement quand on quitte
  l'écran. On remet l'état à `.idle` pour que le chargement reprenne au retour.
- Le Repository vérifie aussi le **code de statut HTTP** : 200 = succès, 404 ou 500 = erreur.
- Le projet n'utilise pas `try?` pour les appels réseau : il ferait disparaître l'erreur, et on ne
  pourrait plus afficher de message (c'était une erreur du cours, chapitre 5).

### 4.10 `Codable` : du JSON vers Swift (chapitre 5)

L'API renvoie du texte au format JSON. `JSONDecoder` le transforme en objets Swift.

**Cas simple avec `CodingKeys`**, dans [MealCategory.swift](Matbakhi/Models/MealCategory.swift).
Les noms du JSON (`strCategory`) ne sont pas ceux qu'on veut en Swift (`name`), alors on fait le lien :

```swift
enum CodingKeys: String, CodingKey {
    case id = "idCategory"
    case name = "strCategory"
    case thumbnailURL = "strCategoryThumb"
    case summary = "strCategoryDescription"
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
| `@EnvironmentObject` | Vue | Objet **partagé** par toute l'app, injecté une seule fois | `AuthService`, `FavoritesService` |
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
   fichier `GoogleService-Info.plist` est présent.
2. `AppDelegate` démarre le SDK des publicités.
3. `MatbakhiApp` crée `AuthService` et `FavoritesService`, les partage avec `.environmentObject(...)`,
   et affiche `RootView` en lui appliquant le thème (`.preferredColorScheme`), la langue
   (`.environment(\.locale, ...)`) et le sens de lecture (`.environment(\.layoutDirection, ...)`).
4. `RootView` commence par `SplashView`, car `showSplash` vaut `true`. Le `.task` du splash lance
   l'animation (le logo tourne et grossit), attend 1,6 seconde puis appelle `onFinish`.
5. `onFinish` met `showSplash` à `false`. SwiftUI recalcule `RootView` :
   - si la présentation n'a jamais été vue, il affiche `OnboardingView` ;
   - sinon, si personne n'est connecté, il affiche `LoginView` ;
   - sinon, il affiche `MainTabView`.
6. Dans la présentation, « Commencer » met `onboardingDone` à `true`. Grâce à `@AppStorage`,
   c'est sauvegardé : aux lancements suivants, la présentation ne revient pas.
7. `MainTabView` affiche `HomeView`, dont le `.task` appelle `viewModel.load()`. L'indicateur de
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
   `.failed("error.network.offline")` sans Internet.
7. **La vue se redessine** et affiche, selon l'état :
   - la grille de cartes ;
   - « Aucune recette ne correspond à votre recherche » ;
   - le message d'erreur avec un bouton « Réessayer ».
8. **L'utilisateur touche une carte.** `NavigationLink(value: meal)` demande au `NavigationStack`
   d'afficher la destination prévue pour un `Meal`, définie dans
   [NavigationDestinations.swift](Matbakhi/Views/Components/NavigationDestinations.swift) :
   c'est `MealDetailView`.
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

## 8. La connexion et les favoris (Firebase)

### Qui fait quoi

| Fichier | Rôle |
|---|---|
| `AuthService` | Toutes les opérations de connexion : se connecter, créer un compte, mot de passe oublié, Google, se déconnecter |
| `FavoritesService` | Lire, ajouter et retirer des favoris dans Firestore |
| `Validation` | Vérifier les champs des formulaires **avant** d'appeler Firebase |
| `FormField` | Un champ de saisie avec son message d'erreur en rouge |

Les deux services sont créés **une seule fois**, dans `MatbakhiApp` (`@StateObject`), puis partagés
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

### Les favoris dans Firestore

```
users/{uid}                         { name, email }            ← profil, créé à l'inscription
users/{uid}/favorites/{idRecette}   { name, thumbnail, area }  ← un document par favori
```

- Toucher ❤️ appelle `FavoritesService.toggle(meal)`, qui crée ou supprime le document.
- `addSnapshotListener` **écoute** la collection : à chaque changement, même depuis un autre
  téléphone, `favorites` est mis à jour. L'écran Favoris et le cœur se redessinent tout seuls.
- **Sécurité** : les règles de [firestore.rules](firestore.rules) n'autorisent chaque utilisateur
  qu'à lire et écrire sous `users/{son uid}`.

---

## 9. Ajouter un nouvel écran : la marche à suivre

Exemple : l'écran « Favoris ». Suivez toujours le même ordre.

1. **Model** (si nouvelles données) dans `Models/`, par exemple `struct FavoriteMeal: Identifiable, Codable`.
2. **Repository** dans `Services/` : un protocole, plus une implémentation (Firestore).
3. **ViewModel** dans `ViewModels/`, sur ce modèle :

   ```swift
   @MainActor
   final class FavoritesViewModel: ObservableObject {
       @Published private(set) var state: LoadState<[FavoriteMeal]> = .idle
       private let repository: FavoritesRepository

       init(repository: FavoritesRepository = FirestoreFavoritesRepository()) {
           self.repository = repository
       }

       func load() async {
           state = .loading
           do {
               let favorites = try await repository.favorites()
               state = favorites.isEmpty ? .empty : .loaded(favorites)
           } catch is CancellationError {
               state = .idle
           } catch {
               state = .failed((error as? NetworkError)?.messageKey ?? "error.unknown")
           }
       }
   }
   ```

4. **Vue** dans `Views/Favorites/` : `@StateObject private var viewModel = FavoritesViewModel()`,
   puis un `switch viewModel.state` qui traite les 5 cas, en réutilisant `LoadingStateView`,
   `ErrorStateView` et `EmptyStateView`.
5. **Navigation** : ajoutez un onglet dans `MainTabView`, ou un `NavigationLink`.
6. **Textes** : ajoutez les clés dans les 3 fichiers `Localizable.strings`.
7. **Sur le Mac**, récupérez le code (`git pull`) puis lancez l'app (⌘R) pour vérifier.
   Avec Xcode 15, ajoutez d'abord les nouveaux fichiers (Add Files to "Matbakhi"…).

---

## 10. Questions possibles à l'oral

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

## 11. Glossaire

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
| **Firebase Authentication** | Service de Google qui gère les comptes (inscription, connexion) |
| **Cloud Firestore** | Base de données de Firebase, organisée en collections et documents |
| **Listener (écouteur)** | Code appelé automatiquement à chaque changement (connexion, données Firestore) |
| **SPM** | *Swift Package Manager* : télécharge et intègre les SDK dans le projet |
