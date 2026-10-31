import XCTest
@testable import Matbakhi

@MainActor
final class SearchViewModelTests: XCTestCase {
    /// Crée le ViewModel avec un faux Repository et sans délai d'attente
    private func makeViewModel(repository: MockMealRepository) -> SearchViewModel {
        SearchViewModel(repository: repository, debounce: .zero)
    }

    func testSearchSuccessShowsResults() async {
        // Arrange
        let repository = MockMealRepository()
        repository.meals = [.preview]
        let viewModel = makeViewModel(repository: repository)
        viewModel.query = "shak"

        // Act
        await viewModel.search()

        // Assert
        XCTAssertEqual(viewModel.state, .loaded([.preview]))
    }

    func testSearchWithoutResultShowsEmptyState() async {
        let viewModel = makeViewModel(repository: MockMealRepository())
        viewModel.query = "zzzz"

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .empty)
    }

    func testSearchOfflineShowsErrorMessage() async {
        let repository = MockMealRepository()
        repository.error = NetworkError.noConnection
        let viewModel = makeViewModel(repository: repository)
        viewModel.query = "pasta"

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .failed("error.network.offline"))
    }

    func testQueryTooShortDoesNotCallTheAPI() async {
        let repository = MockMealRepository()
        let viewModel = makeViewModel(repository: repository)
        viewModel.query = "a"

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(repository.searchCallCount, 0)
    }
}
