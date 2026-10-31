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

enum NetworkError: Error, Equatable {
    case invalidURL
    case noConnection
    case server(statusCode: Int)
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
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

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

    // MARK: - Requête GET générique

    private func get<T: Decodable>(_ path: String, query: [String: String] = [:]) async throws -> T {
        var components = URLComponents(string: baseURL + path)
        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components?.url else { throw NetworkError.invalidURL }

        let result: (Data, URLResponse)
        do {
            result = try await session.data(from: url)
        } catch {
            // Requête annulée (ex. : l'utilisateur tape une nouvelle recherche) : ce n'est pas une erreur
            if (error as? URLError)?.code == .cancelled || error is CancellationError {
                throw CancellationError()
            }
            throw NetworkError.noConnection
        }
        let (data, response) = result

        // On vérifie le code de statut HTTP (200 = succès, 404/500 = erreur)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NetworkError.server(statusCode: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding
        }
    }
}
