import Foundation

/// Contrat d'accès aux recettes (chapitre 5 : pattern Repository).
/// Les ViewModels dépendent de ce protocole, pas de l'API : en test on injecte un mock.
protocol MealRepository {
    func searchMeals(query: String) async throws -> [Meal]
    func mealDetail(id: String) async throws -> Meal?
    func randomMeal() async throws -> Meal?
    func categories() async throws -> [MealCategory]
    func meals(from source: MealListSource) async throws -> [Meal]
}

enum NetworkError: Error {
    case invalidURL
    case noConnection
    case server
    case decoding

    /// Clé de traduction du message affiché à l'utilisateur
    var messageKey: String {
        switch self {
        case .invalidURL: return "error.network.invalidURL"
        case .noConnection: return "error.network.offline"
        case .server: return "error.network.server"
        case .decoding: return "error.network.decoding"
        }
    }
}

/// Implémentation réelle : appelle l'API REST TheMealDB (gratuite, sans clé)
final class TheMealDBRepository: MealRepository {
    private let baseURL = "https://www.themealdb.com/api/json/v1/1/"

    func searchMeals(query: String) async throws -> [Meal] {
        let response: MealsResponse = try await get("search.php", query: ["s": query])
        return response.meals ?? []
    }

    func mealDetail(id: String) async throws -> Meal? {
        let response: MealsResponse = try await get("lookup.php", query: ["i": id])
        return response.meals?.first
    }

    func randomMeal() async throws -> Meal? {
        let response: MealsResponse = try await get("random.php")
        return response.meals?.first
    }

    func categories() async throws -> [MealCategory] {
        let response: CategoriesResponse = try await get("categories.php")
        return response.categories
    }

    func meals(from source: MealListSource) async throws -> [Meal] {
        let query: [String: String]
        switch source {
        case .category(let name): query = ["c": name]
        case .area(let area): query = ["a": area]
        }
        let response: MealsResponse = try await get("filter.php", query: query)
        return response.meals ?? []
    }

    // MARK: - Requête GET commune à tous les appels

    private func get<T: Decodable>(_ path: String, query: [String: String] = [:]) async throws -> T {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components?.url else { throw NetworkError.invalidURL }

        let result: (Data, URLResponse)
        do {
            result = try await URLSession.shared.data(from: url)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()   // écran quitté pendant le chargement : ce n'est pas une erreur
        } catch {
            throw NetworkError.noConnection
        }
        let (data, response) = result

        // Code de statut HTTP : 200 = succès, 404 / 500 = erreur
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw NetworkError.server
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding
        }
    }
}
