import Foundation

@MainActor
final class MealDetailViewModel: ObservableObject {
    @Published private(set) var state: LoadState<Meal>

    let title: String
    private let mealID: String
    private let repository: MealRepository

    init(meal: Meal, repository: MealRepository = TheMealDBRepository()) {
        title = meal.name
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
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed((error as? NetworkError)?.messageKey ?? "error.unknown")
        }
    }
}
