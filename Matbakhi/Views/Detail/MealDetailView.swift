import SwiftUI

struct MealDetailView: View {
    @EnvironmentObject private var favorites: FavoritesService
    @StateObject private var viewModel: MealDetailViewModel
    @State private var showIngredients = false

    private let meal: Meal

    init(meal: Meal) {
        self.meal = meal
        _viewModel = StateObject(wrappedValue: MealDetailViewModel(meal: meal))
    }

    var body: some View {
        content
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Bouton favori : le cœur rebondit quand on le touche
                Button {
                    favorites.toggle(meal)
                } label: {
                    Image(systemName: favorites.isFavorite(meal) ? "heart.fill" : "heart")
                        .foregroundStyle(.red)
                        .symbolEffect(.bounce, value: favorites.isFavorite(meal))
                }
            }
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
        case .loaded(let meal):
            detail(for: meal)
        }
    }

    private func detail(for meal: Meal) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RemoteImage(url: meal.thumbnailURL)
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(alignment: .leading, spacing: 20) {
                    Text(meal.name)
                        .font(.largeTitle.bold())

                    HStack {
                        if let category = meal.category {
                            TagView(text: category, systemImage: "tag.fill")
                        }
                        if let area = meal.area {
                            TagView(text: area, systemImage: "globe.europe.africa.fill")
                        }
                    }

                    // Le contenu des recettes vient de l'API : il est en anglais
                    Label("detail.sourceNote".localized, systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ingredients(of: meal)

                    if let instructions = meal.instructions {
                        Text("detail.instructions".localized)
                            .font(.title2.bold())
                        Text(instructions)
                    }

                    if let youtubeURL = meal.youtubeURL {
                        Link(destination: youtubeURL) {
                            Label("detail.video".localized, systemImage: "play.rectangle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear { showIngredients = true }
    }

    private func ingredients(of meal: Meal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("detail.ingredients".localized)
                .font(.title2.bold())

            // Les ingrédients apparaissent un par un (animation décalée)
            ForEach(Array(meal.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text(ingredient.measure)
                        .foregroundStyle(.secondary)
                }
                .opacity(showIngredients ? 1 : 0)
                .offset(y: showIngredients ? 0 : 12)
                .animation(.spring().delay(Double(index) * 0.05), value: showIngredients)
            }
        }
    }
}

private struct TagView: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.15), in: Capsule())
    }
}

#Preview {
    NavigationStack {
        MealDetailView(meal: .preview)
            .environmentObject(FavoritesService())
    }
}
