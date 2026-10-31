import SwiftUI

enum AppTab: String {
    case home, search, settings
}

struct MainTabView: View {
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

            SettingsView()
                .tabItem { Label("tab.settings".localized, systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
    }
}

#Preview { MainTabView() }
