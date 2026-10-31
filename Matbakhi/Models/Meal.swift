import Foundation

/// Une recette venant de l'API TheMealDB (https://www.themealdb.com/api.php)
struct Meal: Identifiable, Hashable {
    let id: String
    let name: String
    let thumbnailURL: URL?
    let category: String?
    let area: String?
    let instructions: String?
    let youtubeURL: URL?
    let tags: [String]
    let ingredients: [Ingredient]

    /// Les listes (filter.php) ne renvoient que l'id, le nom et l'image :
    /// il faut alors charger le détail avec lookup.php
    var isComplete: Bool { instructions != nil }
}

struct Ingredient: Identifiable, Hashable {
    /// Position de l'ingrédient (1 à 20) : unique dans une recette
    let id: Int
    let name: String
    let measure: String
}

// MARK: - Décodage du JSON de l'API

extension Meal: Decodable {
    init(from decoder: Decoder) throws {
        // Une recette de l'API est un dictionnaire de textes : { "strMeal": "...", "strIngredient1": "...", ... }
        // compactMapValues retire les valeurs null
        let json = try decoder.singleValueContainer().decode([String: String?].self).compactMapValues { $0 }

        // Les champs vides valent "" ou " " : on les transforme en nil
        func text(_ key: String) -> String? {
            let value = json[key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return value.isEmpty ? nil : value
        }

        id = text("idMeal") ?? ""
        name = text("strMeal") ?? ""
        thumbnailURL = text("strMealThumb").flatMap { URL(string: $0) }
        category = text("strCategory")
        area = text("strArea")
        instructions = text("strInstructions")
        youtubeURL = text("strYoutube").flatMap { URL(string: $0) }
        tags = text("strTags")?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? []

        // L'API envoie strIngredient1 ... strIngredient20 : on garde ceux qui sont remplis
        ingredients = (1...20).compactMap { index in
            guard let name = text("strIngredient\(index)") else { return nil }
            return Ingredient(id: index, name: name, measure: text("strMeasure\(index)") ?? "")
        }
    }
}

/// Réponse de search.php, lookup.php, random.php et filter.php
struct MealsResponse: Decodable {
    /// L'API renvoie "meals": null quand il n'y a aucun résultat
    let meals: [Meal]?
}

// MARK: - Exemple pour les aperçus (#Preview)

extension Meal {
    static let preview = Meal(
        id: "preview",
        name: "Shakshuka",
        thumbnailURL: nil,
        category: "Vegetarian",
        area: "Tunisian",
        instructions: "Heat the oil in a frying pan. Add the onion, garlic and peppers...",
        youtubeURL: nil,
        tags: ["Egg", "Breakfast"],
        ingredients: [
            Ingredient(id: 1, name: "Olive Oil", measure: "1 tbs"),
            Ingredient(id: 2, name: "Red Onion", measure: "1 chopped"),
            Ingredient(id: 3, name: "Eggs", measure: "4"),
        ]
    )
}
