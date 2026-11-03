import SwiftUI

enum AppTab: String {
    case home, search, favorites, planning, settings
}

struct MainTabView: View {
    @EnvironmentObject private var favorites: FavoritesService
    @EnvironmentObject private var planning: PlanningService
    @EnvironmentObject private var shopping: ShoppingService
    // @SceneStorage : l'onglet choisi est conservé même quand l'interface est reconstruite
    @SceneStorage("selectedTab") private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("tab.home".localized, systemImage: "house.fill") }
                .tag(AppTab.home)

            SearchView()
                .tabItem { Label("tab.search".localized, systemImage: "magnifyingglass") }
                .tag(AppTab.search)

            FavoritesView()
                .tabItem { Label("tab.favorites".localized, systemImage: "heart.fill") }
                .tag(AppTab.favorites)

            PlanningView()
                .tabItem { Label("tab.planning".localized, systemImage: "calendar") }
                .tag(AppTab.planning)

            SettingsView()
                .tabItem { Label("tab.settings".localized, systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
        // Données Firestore de l'utilisateur connecté, mises à jour en temps réel
        .onAppear {
            favorites.startListening()
            planning.startListening()
            shopping.startListening()
        }
    }
}

extension View {
    /// Destinations communes à tous les onglets : détail d'une recette et liste de recettes
    func mealNavigationDestinations() -> some View {
        self
            .navigationDestination(for: Meal.self) { meal in
                MealDetailView(meal: meal)
            }
            .navigationDestination(for: MealListSource.self) { source in
                MealListView(source: source)
            }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
        .environmentObject(FavoritesService())
        .environmentObject(PlanningService())
        .environmentObject(ShoppingService())
}
