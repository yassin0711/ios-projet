import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

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
            EmptyStateView(
                systemImage: "text.magnifyingglass",
                title: "search.idle.title".localized,
                message: "search.idle.message".localized
            )
        case .loading:
            LoadingStateView()
        case .empty:
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: "search.empty.title".localized,
                message: "search.empty.message".localized
            )
        case .failed(let messageKey):
            ErrorStateView(messageKey: messageKey) {
                Task { await viewModel.search() }
            }
        case .loaded(let meals):
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(meals) { meal in
                        NavigationLink(value: meal) {
                            MealCard(meal: meal)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
}

#Preview { SearchView() }
