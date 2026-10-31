import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var state: LoadState<[Meal]> = .idle

    private let repository: MealRepository

    init(repository: MealRepository = TheMealDBRepository()) {
        self.repository = repository
    }

    /// Appelée quand l'utilisateur appuie sur « Rechercher » au clavier
    func search() async {
        let text = query.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        state = .loading
        do {
            let meals = try await repository.searchMeals(query: text)
            state = meals.isEmpty ? .empty : .loaded(meals)
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed((error as? NetworkError)?.messageKey ?? "error.unknown")
        }
    }
}
