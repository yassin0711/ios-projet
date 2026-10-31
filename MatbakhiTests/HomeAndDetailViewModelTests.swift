import XCTest
@testable import Matbakhi

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testLoadSuccessFillsContent() async {
        // Arrange
        let repository = MockMealRepository()
        repository.random = .preview
        repository.categoryList = [MealCategory(id: "1", name: "Beef", thumbnailURL: nil, summary: "")]
        repository.meals = [.partial(id: "1", name: "Brik")]
        let viewModel = HomeViewModel(repository: repository)

        // Act
        await viewModel.load()

        // Assert
        guard case .loaded(let content) = viewModel.state else {
            return XCTFail("État attendu : loaded, obtenu : \(viewModel.state)")
        }
        XCTAssertEqual(content.featured, .preview)
        XCTAssertEqual(content.categories.map(\.name), ["Beef"])
        XCTAssertEqual(content.tunisianMeals.map(\.name), ["Brik"])
    }

    func testLoadFailureShowsServerError() async {
        let repository = MockMealRepository()
        repository.error = NetworkError.server
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .failed("error.network.server"))
    }

    func testLoadWithoutCategoriesShowsEmptyState() async {
        let viewModel = HomeViewModel(repository: MockMealRepository())

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .empty)
    }
}

@MainActor
final class MealDetailViewModelTests: XCTestCase {
    func testCompleteMealIsShownWithoutNetworkCall() {
        let repository = MockMealRepository()

        let viewModel = MealDetailViewModel(meal: .preview, repository: repository)

        XCTAssertEqual(viewModel.state, .loaded(.preview))
        XCTAssertEqual(repository.detailCallCount, 0)
    }

    func testPartialMealLoadsTheDetail() async {
        let repository = MockMealRepository()
        repository.detail = .preview
        let viewModel = MealDetailViewModel(meal: .partial(id: "1", name: "Brik"), repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .loaded(.preview))
        XCTAssertEqual(repository.detailCallCount, 1)
    }

    func testDetailFailureShowsDecodingError() async {
        let repository = MockMealRepository()
        repository.error = NetworkError.decoding
        let viewModel = MealDetailViewModel(meal: .partial(id: "1", name: "Brik"), repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .failed("error.network.decoding"))
    }
}
