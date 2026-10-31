import Foundation

/// Liste des recettes d'une catégorie ou d'une cuisine (pays)
@MainActor
final class MealListViewModel: ObservableObject {
    @Published private(set) var state: LoadState<[Meal]> = .idle

    let source: MealListSource
    private let repository: MealRepository

    init(source: MealListSource, repository: MealRepository = TheMealDBRepository()) {
        self.source = source
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let meals = try await repository.meals(from: source)
            state = meals.isEmpty ? .empty : .loaded(meals)
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed((error as? NetworkError)?.messageKey ?? "error.unknown")
        }
    }
}
