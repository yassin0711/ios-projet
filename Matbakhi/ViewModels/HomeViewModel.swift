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

    /// - Parameter isRefresh: true pour « tirer pour rafraîchir » : on garde l'écran affiché
    func load(isRefresh: Bool = false) async {
        if !isRefresh { state = .loading }
        do {
            // Les 3 appels partent en parallèle
            async let featured = repository.randomMeal()
            async let categories = repository.categories()
            async let tunisian = repository.meals(from: .area("Tunisian"))

            let content = try await HomeContent(
                featured: featured,
                categories: categories,
                tunisianMeals: tunisian
            )
            let isEmpty = content.featured == nil && content.categories.isEmpty && content.tunisianMeals.isEmpty
            state = isEmpty ? .empty : .loaded(content)
        } catch is CancellationError {
            return
        } catch let error as NetworkError {
            state = .failed(error.messageKey)
        } catch {
            state = .failed("error.unknown")
        }
    }
}
