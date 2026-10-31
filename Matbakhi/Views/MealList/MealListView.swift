import SwiftUI

/// Recettes d'une catégorie ou d'une cuisine
struct MealListView: View {
    @StateObject private var viewModel: MealListViewModel

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    init(source: MealListSource) {
        // @StateObject (et non @ObservedObject) : c'est cette vue qui crée et possède le ViewModel
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
            EmptyStateView(
                systemImage: "fork.knife",
                title: "state.empty.title".localized,
                message: "state.empty.message".localized
            )
        case .failed(let messageKey):
            ErrorStateView(messageKey: messageKey) {
                Task { await viewModel.load() }
            }
        case .loaded(let meals):
            ScrollView {
                LazyVGrid(columns: columns, spacing: 18) {
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

#Preview {
    NavigationStack {
        MealListView(source: .area("Tunisian"))
            .mealNavigationDestinations()
    }
}
