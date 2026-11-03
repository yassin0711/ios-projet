import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favorites: FavoritesService

    var body: some View {
        NavigationStack {
            Group {
                if favorites.meals.isEmpty {
                    ContentUnavailableView("favorites.empty.title".localized, systemImage: "heart",
                                           description: Text("favorites.empty.message".localized))
                } else {
                    MealGrid(meals: favorites.meals)
                }
            }
            .navigationTitle("tab.favorites".localized)
            .mealNavigationDestinations()
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(FavoritesService())
}
