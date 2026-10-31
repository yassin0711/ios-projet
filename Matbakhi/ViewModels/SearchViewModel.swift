import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var state: LoadState<[Meal]> = .idle

    private let repository: MealRepository
    private let debounce: Duration

    /// - Parameter debounce: délai d'attente après la dernière frappe avant d'appeler l'API
    init(repository: MealRepository = TheMealDBRepository(), debounce: Duration = .milliseconds(400)) {
        self.repository = repository
        self.debounce = debounce
    }

    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Appelée via .task(id: query) : SwiftUI annule l'appel précédent à chaque frappe
    func search() async {
        let text = trimmedQuery
        guard text.count >= 2 else {
            state = .idle
            return
        }

        try? await Task.sleep(for: debounce)
        guard !Task.isCancelled else { return }

        state = .loading
        do {
            let meals = try await repository.searchMeals(query: text)
            state = meals.isEmpty ? .empty : .loaded(meals)
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            state = .failed(error.messageKey)
        } catch {
            state = .failed("error.unknown")
        }
    }
}
