import Foundation

/// Une catégorie de recettes (Beef, Dessert, Seafood...)
struct MealCategory: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let thumbnailURL: URL?
    let summary: String

    // Les noms du JSON ne correspondent pas à nos propriétés : CodingKeys fait le lien
    enum CodingKeys: String, CodingKey {
        case id = "idCategory"
        case name = "strCategory"
        case thumbnailURL = "strCategoryThumb"
        case summary = "strCategoryDescription"
    }
}

struct CategoriesResponse: Decodable {
    let categories: [MealCategory]
}

/// Ce qu'affiche un écran « liste de recettes » : une catégorie ou une cuisine (pays)
enum MealListSource: Hashable {
    case category(String)
    case area(String)

    var title: String {
        switch self {
        case .category(let name):
            return name
        case .area(let area):
            return area == "Tunisian" ? "home.tunisian".localized : area
        }
    }
}
