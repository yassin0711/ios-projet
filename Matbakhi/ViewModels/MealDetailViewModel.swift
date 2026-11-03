import Foundation

@MainActor
final class MealDetailViewModel: ObservableObject {
    @Published private(set) var state: LoadState<Meal>

    private let mealID: String
    private let repository: MealRepository

    init(meal: Meal, repository: MealRepository = TheMealDBRepository()) {
        mealID = meal.id
        self.repository = repository
        // Recette déjà complète (recherche, recette du jour) : rien à charger
        state = meal.isComplete ? .loaded(meal) : .idle
    }

    func load() async {
        state = .loading
        do {
            if let meal = try await repository.mealDetail(id: mealID) {
                state = .loaded(meal)
            } else {
                state = .empty
            }
        } catch {
            // Écran quitté pendant le chargement (tâche annulée) : on rechargera au retour
            state = Task.isCancelled ? .idle : .failed(error)
        }
    }
}
