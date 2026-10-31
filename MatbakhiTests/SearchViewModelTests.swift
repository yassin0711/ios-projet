import XCTest
@testable import Matbakhi

@MainActor
final class SearchViewModelTests: XCTestCase {
    func testSearchSuccessShowsResults() async {
        // Arrange
        let repository = MockMealRepository()
        repository.meals = [.preview]
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "shak"

        // Act
        await viewModel.search()

        // Assert
        XCTAssertEqual(viewModel.state, .loaded([.preview]))
    }

    func testSearchWithoutResultShowsEmptyState() async {
        let viewModel = SearchViewModel(repository: MockMealRepository())
        viewModel.query = "zzzz"

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .empty)
    }

    func testSearchOfflineShowsErrorMessage() async {
        let repository = MockMealRepository()
        repository.error = NetworkError.noConnection
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "pasta"

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .failed("error.network.offline"))
    }

    func testEmptyQueryDoesNotCallTheAPI() async {
        let repository = MockMealRepository()
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "   "

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(repository.searchCallCount, 0)
    }
}
