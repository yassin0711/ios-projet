import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("tab.search".localized)
                .searchable(text: $viewModel.query, prompt: "search.prompt".localized)
                .onSubmit(of: .search) {
                    Task { await viewModel.search() }
                }
                .mealNavigationDestinations()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView("search.idle.title".localized, systemImage: "text.magnifyingglass",
                                   description: Text("search.idle.message".localized))
        case .loading:
            LoadingStateView()
        case .empty:
            ContentUnavailableView("search.empty.title".localized, systemImage: "magnifyingglass",
                                   description: Text("search.empty.message".localized))
        case .failed(let error):
            ErrorStateView(error: error) {
                Task { await viewModel.search() }
            }
        case .loaded(let meals):
            MealGrid(meals: meals)
        }
    }
}

#Preview { SearchView() }
