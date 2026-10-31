import Foundation
@testable import Matbakhi

/// Faux Repository (chapitre 6 : mocking) : aucune requête réseau, résultats prévisibles
final class MockMealRepository: MealRepository {
    var meals: [Meal] = []
    var categoryList: [MealCategory] = []
    var random: Meal?
    var detail: Meal?
    /// Si défini, toutes les méthodes échouent avec cette erreur
    var error: Error?

    private(set) var searchCallCount = 0
    private(set) var detailCallCount = 0

    func searchMeals(query: String) async throws -> [Meal] {
        searchCallCount += 1
        if let error { throw error }
        return meals
    }

    func mealDetail(id: String) async throws -> Meal? {
        detailCallCount += 1
        if let error { throw error }
        return detail
    }

    func randomMeal() async throws -> Meal? {
        if let error { throw error }
        return random
    }

    func categories() async throws -> [MealCategory] {
        if let error { throw error }
        return categoryList
    }

    func meals(from source: MealListSource) async throws -> [Meal] {
        if let error { throw error }
        return meals
    }
}

extension Meal {
    /// Recette partielle, comme celles renvoyées par filter.php (sans instructions)
    static func partial(id: String, name: String) -> Meal {
        Meal(id: id, name: name, thumbnailURL: nil, category: nil, area: nil,
             instructions: nil, youtubeURL: nil, tags: [], ingredients: [])
    }
}
