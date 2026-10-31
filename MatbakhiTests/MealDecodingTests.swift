import XCTest
@testable import Matbakhi

final class MealDecodingTests: XCTestCase {
    func testDecodeFullMealIgnoresEmptyIngredients() throws {
        // Arrange : extrait réaliste du JSON de TheMealDB (champs vides, null et espaces)
        let json = """
        {
          "meals": [{
            "idMeal": "52772",
            "strMeal": "Teriyaki Chicken Casserole",
            "strCategory": "Chicken",
            "strArea": "Japanese",
            "strInstructions": "Preheat oven to 350.",
            "strMealThumb": "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
            "strTags": "Meat, Casserole",
            "strYoutube": "",
            "strIngredient1": "soy sauce",
            "strMeasure1": "3/4 cup",
            "strIngredient2": "water",
            "strMeasure2": "1/2 cup",
            "strIngredient3": " ",
            "strMeasure3": " ",
            "strIngredient4": null,
            "strMeasure4": null
          }]
        }
        """.data(using: .utf8)!

        // Act
        let response = try JSONDecoder().decode(MealsResponse.self, from: json)
        let meal = try XCTUnwrap(response.meals?.first)

        // Assert
        XCTAssertEqual(meal.id, "52772")
        XCTAssertEqual(meal.area, "Japanese")
        XCTAssertEqual(meal.tags, ["Meat", "Casserole"])
        XCTAssertNil(meal.youtubeURL, "Une chaîne vide doit devenir nil")
        XCTAssertEqual(meal.ingredients.map(\.name), ["soy sauce", "water"])
        XCTAssertEqual(meal.ingredients.first?.measure, "3/4 cup")
        XCTAssertTrue(meal.isComplete)
    }

    func testDecodePartialMealFromFilterEndpoint() throws {
        let json = """
        {"meals": [{"strMeal": "Couscous", "strMealThumb": "https://example.com/c.jpg", "idMeal": "1"}]}
        """.data(using: .utf8)!

        let meal = try XCTUnwrap(JSONDecoder().decode(MealsResponse.self, from: json).meals?.first)

        XCTAssertEqual(meal.name, "Couscous")
        XCTAssertTrue(meal.ingredients.isEmpty)
        XCTAssertFalse(meal.isComplete)
    }

    func testDecodeNullMealsMeansNoResult() throws {
        let json = #"{"meals": null}"#.data(using: .utf8)!

        let response = try JSONDecoder().decode(MealsResponse.self, from: json)

        XCTAssertNil(response.meals)
    }
}
