import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("tab.search".localized)
                .searchable(text: $viewModel.query, prompt: "search.prompt".localized)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .mealNavigationDestinations()
        }
        // Relancée à chaque frappe : la recherche précédente est annulée automatiquement
        .task(id: viewModel.query) {
            await viewModel.search()
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
                message: "search.empty.message".localized(with: viewModel.trimmedQuery)
            )
        case .failed(let messageKey):
            ErrorStateView(messageKey: messageKey) {
                Task { await viewModel.search() }
            }
        case .loaded(let meals):
            ScrollView {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(meals) { meal in
                        NavigationLink(value: meal) {
                            MealCard(meal: meal)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                }
                .padding()
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: meals)
            }
        }
    }
}

#Preview { SearchView() }
