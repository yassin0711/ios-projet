# Matbakhi (مطبخي) — mini-projet iOS

Application de recettes en SwiftUI : recettes du monde et de Tunisie (API TheMealDB), favoris,
planning des repas de la semaine, liste de courses et recettes partagées par la communauté (Firebase).

> Le nom et l'angle « Tunisie + planning + communauté » rendent le sujet distinct d'une simple app
> de recettes : les projets similaires entre équipes sont notés 0.

📘 **Vous débutez en Swift ?** Lisez [GUIDE_DU_PROJET.md](GUIDE_DU_PROJET.md) : il explique le projet
fichier par fichier, avec les notions du cours.

## Exigences du sujet → où elles sont traitées

| Exigence | Implémentation | État |
|---|---|---|
| SwiftUI | Toute l'app | ✅ |
| Firebase Authentication (email/mot de passe + Google) | Connexion, Inscription, Mot de passe oublié | ⏳ |
| Cloud Firestore | Profil, favoris, planning, courses, communauté | ⏳ |
| Au moins 9 interfaces | 16 prévues (voir ci-dessous) | 7 faites |
| Navigation | `TabView` + `NavigationStack` + sheets | ✅ (à compléter) |
| Formulaires avec validation | Connexion, inscription, créer une recette, profil | ⏳ |
| API REST | TheMealDB (gratuite, sans clé) via `MealRepository` | ✅ |
| Animations | Splash, présentation, cartes (rebond au toucher), ingrédients qui apparaissent un par un, chargement | ✅ (d'autres à venir) |
| Thème clair / sombre modifiable | Réglages → Apparence | ✅ |
| Multilingue FR / EN / AR (droite à gauche) | Réglages → Langue | ✅ |
| Chargement, erreurs, états vides | `LoadState` + `LoadingStateView` / `ErrorStateView` / `EmptyStateView` | ✅ |
| Google Mobile Ads : Banner + Interstitial (ID de test) | SDK installé et démarré, ID de test dans `project.yml` | ⏳ |
| Bonus : hors ligne | Cache des favoris avec SwiftData | ⏳ optionnel |
| Bonus : widget iOS | Widget « Recette du jour » | ⏳ optionnel |

## Les écrans

| # | Écran | État |
|---|---|---|
| 1 | Splash animé | ✅ |
| 2 | Présentation (3 pages) | ✅ |
| 3 | Connexion (email + Google) | ⏳ |
| 4 | Inscription | ⏳ |
| 5 | Mot de passe oublié | ⏳ |
| 6 | Accueil (recette du jour, catégories, saveurs de Tunisie) | ✅ |
| 7 | Recherche | ✅ |
| 8 | Liste par catégorie / cuisine | ✅ |
| 9 | Détail d'une recette | ✅ (boutons favori et planning à ajouter) |
| 10 | Favoris | ⏳ |
| 11 | Planning de la semaine | ⏳ |
| 12 | Liste de courses | ⏳ |
| 13 | Communauté (recettes publiées) | ⏳ |
| 14 | Créer une recette (formulaire) | ⏳ |
| 15 | Profil / modifier le profil | ⏳ |
| 16 | Réglages | ✅ |

## Répartition dans l'équipe

Chaque membre doit pouvoir présenter et expliquer sa partie.

| Membre | Partie | Écrans |
|---|---|---|
| 1 | Authentification et profil : Firebase Auth, Google Sign-In, validation des formulaires | 3, 4, 5, 15 |
| 2 | API et découverte : Repository, Codable, états chargement/erreur/vide, tests unitaires | 6, 7, 8, 9 |
| 3 | Firestore : favoris, planning, courses, communauté | 10, 11, 12, 13, 14 |
| 4 | Expérience : thème, langues, animations, publicités AdMob, bonus | 1, 2, 16 + pubs |

À 3 membres : les tâches du membre 4 sont réparties entre les membres 1 et 2.

## Architecture (MVVM + Repository, chapitres 3, 5 et 6)

```
View (SwiftUI)  →  ViewModel (ObservableObject, @Published)  →  Repository (protocol)  →  API / Firestore
```

```
Matbakhi/
├── project.yml              Description du projet Xcode (XcodeGen)
├── Matbakhi/
│   ├── App/                 Point d'entrée, aiguillage, onglets
│   ├── Core/                Thème, langue, traductions, LoadState
│   ├── Models/              Meal, MealCategory (Codable + CodingKeys)
│   ├── Services/            MealRepository (API TheMealDB)
│   ├── ViewModels/          Un ViewModel par écran
│   ├── Views/               Écrans et composants réutilisables
│   └── Resources/           Traductions fr/en/ar, images, icône
└── MatbakhiTests/           Tests unitaires avec un faux Repository
```

Règles suivies dans le code :
- La vue qui **crée** un ViewModel utilise `@StateObject` ; une vue qui le **reçoit** utilise `@ObservedObject`.
- Les ViewModels sont `@MainActor` (ils modifient l'interface).
- Les ViewModels reçoivent leur Repository dans `init` (injection de dépendances) : en test, on passe `MockMealRepository`.
- Les erreurs ne sont jamais avalées par un `try?` : elles deviennent un message traduit (`LoadState.failed`).
- Les textes passent par `"clé".localized` (fichiers `Resources/<langue>.lproj/Localizable.strings`).

### Modèle de données Firestore prévu

```
users/{uid}                      nom, email, photo, date d'inscription
users/{uid}/favorites/{mealId}   nom, image, date d'ajout
users/{uid}/mealPlan/{jour}      déjeuner, dîner (id + nom des recettes)
users/{uid}/shoppingItems/{id}   ingrédient, quantité, coché
recipes/{id}                     recette publiée : auteur, titre, ingrédients, étapes, date
recipes/{id}/reviews/{uid}       note, commentaire
```

## Travailler sans Mac (depuis Windows)

Windows ne peut ni compiler ni lancer une app iOS : il faut Xcode, donc macOS. Le projet est organisé
pour qu'on puisse **écrire le code sur Windows** et **le faire compiler par un Mac de GitHub** :

1. Le projet Xcode n'est pas stocké : il est décrit en texte dans `project.yml` et généré par XcodeGen.
2. À chaque `push` sur `main`, le workflow `.github/workflows/ios.yml` démarre un Mac chez GitHub qui :
   - génère le projet et compile l'app ;
   - lance les tests unitaires ;
   - prend 3 captures d'écran (clair en français, sombre en anglais, arabe), téléchargeables dans
     l'onglet **Actions** → le run → **Artifacts** → `captures-ecran`.
3. Le Mac de l'école sert à tester en interactif (simulateur) et à préparer la démo.

**Le dépôt GitHub doit être privé** : en public, une autre équipe pourrait copier le projet (note de 0).
Sur un dépôt privé, les minutes de Mac sont limitées (1 minute macOS compte pour 10 minutes : environ
200 minutes de Mac par mois en gratuit, 300 avec le GitHub Student Developer Pack ; à vérifier, les quotas
changent). Un build prend environ 10 minutes la première fois, puis moins grâce au cache.
Lancez donc le CI quand une fonctionnalité est prête, pas à chaque petite modification.

Autres solutions pour avoir un Mac en interactif :
- un membre de l'équipe qui possède un Mac ;
- un Mac loué dans le cloud (MacinCloud, Scaleway, AWS EC2 Mac), payant, à l'heure ou au mois.

Les machines virtuelles macOS sur PC (« Hackintosh ») sont déconseillées : contraires à la licence
d'Apple et instables avec Xcode.

## Mise en place

### 1. Dépôt GitHub (une seule fois, par un membre)

```bash
cd Matbakhi
git init -b main
git add .
git commit -m "Base du projet Matbakhi"
# Créer un dépôt PRIVÉ vide sur github.com, puis :
git remote add origin https://github.com/<compte>/matbakhi.git
git push -u origin main
```
Ajoutez ensuite les autres membres dans Settings → Collaborators.

### 2. Firebase (une seule fois, par un membre)

1. Sur https://console.firebase.google.com : créer un projet « Matbakhi ».
2. Ajouter une app iOS avec l'identifiant de bundle **`com.matbakhi.app`**.
3. Télécharger `GoogleService-Info.plist` et le placer dans `Matbakhi/Resources/`.
4. Authentication → Sign-in method : activer **E-mail/Mot de passe** et **Google**.
5. Firestore Database → créer la base (mode test au début, règles de sécurité à écrire ensuite).

Sans ce fichier, l'app se lance quand même (partie recettes), mais la connexion ne fonctionne pas.

### 3. Sur un Mac (école ou autre)

```bash
brew install xcodegen      # une seule fois
cd Matbakhi
xcodegen generate          # à refaire après chaque ajout/suppression de fichier
open Matbakhi.xcodeproj
```
Dans Xcode : choisir un simulateur iPhone puis ⌘R pour lancer, ⌘U pour les tests.
Pour un iPhone réel : Signing & Capabilities → choisir votre équipe (Apple ID gratuit suffisant).

## Prochaines étapes

1. Authentification : Connexion, Inscription, Mot de passe oublié, Google Sign-In.
2. Firestore : profil, favoris (bouton cœur animé sur le détail), planning, liste de courses.
3. Communauté : liste des recettes publiées + formulaire « Créer une recette » avec validation.
4. Publicités : bannière sur l'accueil, interstitielle après quelques recettes consultées.
5. Bonus : favoris disponibles hors ligne (SwiftData), widget « Recette du jour ».
