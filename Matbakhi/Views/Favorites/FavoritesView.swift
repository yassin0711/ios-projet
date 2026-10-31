import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var store: FavoritesService

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            Group {
                if store.favorites.isEmpty {
                    EmptyStateView(
                        systemImage: "heart",
                        title: "favorites.empty.title".localized,
                        message: "favorites.empty.message".localized
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(store.favorites) { meal in
                                NavigationLink(value: meal) {
                                    MealCard(meal: meal)
                                }
                                .buttonStyle(PressableButtonStyle())
                            }
                        }
                        .padding()
                    }
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
