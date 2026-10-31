import Foundation

@MainActor
final class MealDetailViewModel: ObservableObject {
    @Published private(set) var state: LoadState<Meal>

    private let meal: Meal
    private let repository: MealRepository

    init(meal: Meal, repository: MealRepository = TheMealDBRepository()) {
        self.meal = meal
        self.repository = repository
        // Si la recette est déjà complète (recherche, recette du jour), pas besoin d'appel réseau
        self.state = meal.isComplete ? .loaded(meal) : .idle
    }

    var title: String { meal.name }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            if let detail = try await repository.mealDetail(id: meal.id) {
                state = .loaded(detail)
            } else {
                state = .empty
            }
        } catch is CancellationError {
            state = .idle
        } catch let error as NetworkError {
            state = .failed(error.messageKey)
        } catch {
            state = .failed("error.unknown")
        }
    }
}
