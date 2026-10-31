import Foundation

struct HomeContent: Equatable {
    let featured: Meal?
    let categories: [MealCategory]
    let tunisianMeals: [Meal]
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var state: LoadState<HomeContent> = .idle

    private let repository: MealRepository

    /// Injection de dépendances (chapitre 6) : en test on passe un faux Repository
    init(repository: MealRepository = TheMealDBRepository()) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let featured = try await repository.randomMeal()
            let categories = try await repository.categories()
            let tunisianMeals = try await repository.meals(from: .area("Tunisian"))

            let content = HomeContent(featured: featured, categories: categories, tunisianMeals: tunisianMeals)
            state = categories.isEmpty ? .empty : .loaded(content)
        } catch is CancellationError {
            state = .idle   // écran quitté pendant le chargement : on rechargera au retour
        } catch {
            state = .failed((error as? NetworkError)?.messageKey ?? "error.unknown")
        }
    }
}
