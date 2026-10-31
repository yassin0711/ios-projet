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
| Firebase Authentication (email/mot de passe + Google) | `AuthService` : Connexion, Inscription, Mot de passe oublié, bouton Google | ✅ (à tester avec le fichier Firebase) |
| Cloud Firestore | Profil (`users/{uid}`) et favoris en temps réel (`FavoritesService`) ✅ ; planning, courses, communauté ⏳ | ✅ partiel |
| Au moins 9 interfaces | 16 prévues (voir ci-dessous) | 11 faites ✅ |
| Navigation | `TabView` + `NavigationStack` + sheets | ✅ (à compléter) |
| Formulaires avec validation | `Validation` + `FormField` : connexion, inscription, mot de passe oublié ✅ ; créer une recette ⏳ | ✅ partiel |
| API REST | TheMealDB (gratuite, sans clé) via `MealRepository` | ✅ |
| Animations | Splash, présentation, cartes (rebond au toucher), ingrédients qui apparaissent un par un, cœur des favoris qui rebondit, chargement | ✅ (d'autres à venir) |
| Thème clair / sombre modifiable | Réglages → Apparence | ✅ |
| Multilingue FR / EN / AR (droite à gauche) | Réglages → Langue | ✅ |
| Chargement, erreurs, états vides | `LoadState` + `LoadingStateView` / `ErrorStateView` / `EmptyStateView` | ✅ |
| Google Mobile Ads : Banner + Interstitial (ID de test) | SDK démarré dans `AppDelegate`, identifiant de test dans l'onglet Info d'Xcode | ⏳ |
| Bonus : hors ligne | Cache des favoris avec SwiftData | ⏳ optionnel |
| Bonus : widget iOS | Widget « Recette du jour » | ⏳ optionnel |

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
| 9 | Détail d'une recette (+ bouton favori) | ✅ (bouton planning à ajouter) |
| 10 | Favoris | ✅ |
| 11 | Planning de la semaine | ⏳ |
| 12 | Liste de courses | ⏳ |
| 13 | Communauté (recettes publiées) | ⏳ |
| 14 | Créer une recette (formulaire) | ⏳ |
| 15 | Profil / modifier le profil | ⏳ |
| 16 | Réglages (+ compte et déconnexion) | ✅ |

## Répartition dans l'équipe

Chaque membre doit pouvoir présenter et expliquer sa partie.

| Membre | Partie | Écrans |
|---|---|---|
| 1 | Authentification et profil : Firebase Auth, Google Sign-In, validation des formulaires | 3, 4, 5, 15 |
| 2 | API et découverte : Repository, Codable, états chargement/erreur/vide | 6, 7, 8, 9 |
| 3 | Firestore : favoris, planning, courses, communauté | 10, 11, 12, 13, 14 |
| 4 | Expérience : thème, langues, animations, publicités AdMob, bonus | 1, 2, 16 + pubs |

À 3 membres : les tâches du membre 4 sont réparties entre les membres 1 et 2.

## Architecture (MVVM + Repository, chapitres 3, 5 et 6)

```
View (SwiftUI)  →  ViewModel (ObservableObject, @Published)  →  Repository (protocol)  →  API / Firestore
```

```
Matbakhi/
├── Matbakhi.xcodeproj       Projet Xcode (à créer une fois sur le Mac, voir « Mise en place »)
├── Matbakhi/
│   ├── App/                 Point d'entrée, aiguillage, onglets
│   ├── Core/                Thème, langue, traductions, LoadState, Validation
│   ├── Models/              Meal, MealCategory (Codable + CodingKeys)
│   ├── Services/            MealRepository (API), AuthService (connexion), FavoritesService (Firestore)
│   ├── ViewModels/          Un ViewModel par écran
│   ├── Views/               Écrans et composants réutilisables
│   └── Resources/           Traductions fr/en/ar, images, icône
└── firestore.rules          Règles de sécurité Firestore (à publier dans la console)
```

Règles suivies dans le code :
- La vue qui **crée** un ViewModel utilise `@StateObject` ; une vue qui le **reçoit** utilise `@ObservedObject`.
- Les ViewModels sont `@MainActor` (ils modifient l'interface).
- Les ViewModels reçoivent leur Repository dans `init` (injection de dépendances, chapitre 6).
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

### 3. Créer le projet Xcode (une seule fois, sur le Mac de l'école)

Le dépôt contient le code (dossier `Matbakhi/`) mais pas encore de projet Xcode. Un membre le crée
une fois, puis l'envoie sur GitHub pour toute l'équipe.

**a. Créer un projet vide**

1. Récupérer le code : `git clone https://github.com/yassin0711/ios-projet.git`
2. Copier `GoogleService-Info.plist` dans `ios-projet/Matbakhi/Resources/`.
3. Xcode → **File → New → Project…** → iOS → **App** → Next.
4. Product Name : `Matbakhi` · Organization Identifier : `com.matbakhi` · Interface : **SwiftUI** ·
   Language : **Swift** · Testing System : **None** · Storage : **None**.
5. Enregistrer dans un dossier **temporaire** (par exemple le Bureau), **pas** dans le dépôt.
6. Fermer Xcode. Déplacer **uniquement** `Matbakhi.xcodeproj` du dossier temporaire vers
   `ios-projet/`, à côté du dossier `Matbakhi/`. Supprimer le dossier temporaire.
7. Ouvrir `ios-projet/Matbakhi.xcodeproj`.
   - **Xcode 16 ou plus récent** : le dossier `Matbakhi` du code apparaît tout seul, avec tous les fichiers.
   - **Xcode 15** : supprimer les fichiers en rouge (clic droit → Delete → *Remove Reference*), puis
     clic droit sur le groupe `Matbakhi` → **Add Files to "Matbakhi"…** → sélectionner les dossiers
     `App`, `Core`, `Models`, `Services`, `ViewModels`, `Views`, `Resources` → cible `Matbakhi` cochée → Add.

**b. Ajouter les SDK** (File → **Add Package Dependencies…**, une ligne à la fois)

| Adresse à coller | Version (« Up to Next Major ») | Produits à cocher |
|---|---|---|
| `https://github.com/firebase/firebase-ios-sdk` | 11.0.0 | FirebaseAuth, FirebaseFirestore |
| `https://github.com/google/GoogleSignIn-iOS` | 8.0.0 | GoogleSignIn |
| `https://github.com/googleads/swift-package-manager-google-mobile-ads` | 12.0.0 | GoogleMobileAds |

Ces versions sont celles avec lesquelles le code a été compilé et testé.

**c. Régler la cible** (clic sur le projet bleu → cible **Matbakhi**)

| Onglet | Réglage | Valeur |
|---|---|---|
| General | Bundle Identifier | `com.matbakhi.app` |
| General | Minimum Deployments | iOS **17.0** |
| Info | Custom iOS Target Properties → **+** → `GADApplicationIdentifier` (String) | `ca-app-pub-3940256099942544~1458002511` (identifiant de **test** Google : sans lui, l'app plante au lancement) |
| Info | URL Types → **+** → URL Schemes | la valeur de `REVERSED_CLIENT_ID` dans `GoogleService-Info.plist` (pour la connexion Google) |
| Build Settings | Other Linker Flags | `-ObjC` |
| Build Settings | Swift Language Version | **Swift 5** |
| Build Settings | Default Actor Isolation (si le réglage existe) | **nonisolated** |
| Build Settings | Strict Concurrency Checking | **Minimal** |

Si la compilation affiche une erreur sur **Development Assets** (dossier « Preview Content »
introuvable) : Build Settings → chercher « Development Assets » → effacer la valeur.

**d. Lancer et partager**

1. Choisir un simulateur iPhone en haut de la fenêtre, puis **⌘R**.
2. Si tout fonctionne, envoyer le projet Xcode pour l'équipe :
   ```bash
   git add Matbakhi.xcodeproj
   git commit -m "Ajout du projet Xcode"
   git push
   ```
3. Les autres membres font `git pull`, copient `GoogleService-Info.plist`, et ouvrent `Matbakhi.xcodeproj`.

Avec Xcode 16 ou plus récent, les fichiers ajoutés plus tard dans `Matbakhi/` apparaissent tout seuls.
Avec Xcode 15, il faut les ajouter avec **Add Files to "Matbakhi"…**.

## Prochaines étapes

1. ~~Authentification : Connexion, Inscription, Mot de passe oublié, Google Sign-In.~~ ✅
2. Firestore : ~~profil, favoris~~ ✅, planning, liste de courses.
3. Communauté : liste des recettes publiées + formulaire « Créer une recette » avec validation.
4. Publicités : bannière sur l'accueil, interstitielle après quelques recettes consultées.
5. Bonus : favoris disponibles hors ligne (SwiftData), widget « Recette du jour ».
