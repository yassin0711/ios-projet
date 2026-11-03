import SwiftUI

/// Recettes d'une catégorie ou d'une cuisine
struct MealListView: View {
    @StateObject private var viewModel: MealListViewModel

    init(source: MealListSource) {
        // @StateObject : c'est cette vue qui crée et possède le ViewModel
        _viewModel = StateObject(wrappedValue: MealListViewModel(source: source))
    }

    var body: some View {
        content
            .navigationTitle(viewModel.source.title)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if case .idle = viewModel.state {
                    await viewModel.load()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingStateView()
        case .empty:
            ContentUnavailableView("state.empty.title".localized, systemImage: "fork.knife",
                                   description: Text("state.empty.message".localized))
        case .failed(let error):
            ErrorStateView(error: error) {
                Task { await viewModel.load() }
            }
        case .loaded(let meals):
            MealGrid(meals: meals)
        }
    }
}

#Preview {
    NavigationStack {
        MealListView(source: .area("Tunisian"))
            .mealNavigationDestinations()
    }
}
