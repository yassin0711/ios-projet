import SwiftUI

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
