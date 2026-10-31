import SwiftUI

enum AppTab: String {
    case home, search, favorites, settings
}

struct MainTabView: View {
    @EnvironmentObject private var favorites: FavoritesService
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

            SettingsView()
                .tabItem { Label("tab.settings".localized, systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
        .onAppear { favorites.startListening() }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
        .environmentObject(FavoritesService())
}
