import SwiftUI

struct PlanningView: View {
    @EnvironmentObject private var planning: PlanningService

    var body: some View {
        NavigationStack {
            Group {
                if planning.meals.isEmpty {
                    ContentUnavailableView("planning.empty.title".localized, systemImage: "calendar",
                                           description: Text("planning.empty.message".localized))
                } else {
                    List {
                        ForEach(WeekDay.allCases) { day in
                            Section(day.titleKey.localized) {
                                row(for: day)
                            }
                        }
                    }
                }
            }
            .navigationTitle("tab.planning".localized)
            .toolbar {
                // Bouton panier : ouvre la liste de courses
                NavigationLink {
                    ShoppingListView()
                } label: {
                    Image(systemName: "cart")
                }
            }
            .mealNavigationDestinations()
        }
    }

    @ViewBuilder
    private func row(for day: WeekDay) -> some View {
        if let meal = planning.meals[day] {
            NavigationLink(value: meal) {
                HStack(spacing: 12) {
                    RemoteImage(url: meal.thumbnailURL)
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text(meal.name)
                }
            }
            // Glisser vers la gauche pour retirer la recette de ce jour
            .swipeActions {
                Button("planning.remove".localized, role: .destructive) {
                    planning.remove(day)
                }
            }
        } else {
            Text("planning.noMeal".localized)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PlanningView()
        .environmentObject(PlanningService())
        .environmentObject(ShoppingService())
}
