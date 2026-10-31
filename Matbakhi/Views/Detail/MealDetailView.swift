import SwiftUI

struct MealDetailView: View {
    @StateObject private var viewModel: MealDetailViewModel
    @State private var showIngredients = false

    init(meal: Meal) {
        _viewModel = StateObject(wrappedValue: MealDetailViewModel(meal: meal))
    }

    var body: some View {
        content
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadIfNeeded() }
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
            VStack(alignment: .leading, spacing: 0) {
                RemoteImage(url: meal.thumbnailURL)
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(alignment: .leading, spacing: 20) {
                    header(for: meal)
                    ingredientsSection(for: meal)
                    instructionsSection(for: meal)

                    if let youtubeURL = meal.youtubeURL {
                        Link(destination: youtubeURL) {
                            Label("detail.video".localized, systemImage: "play.rectangle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .padding()
            }
        }
        .onAppear { showIngredients = true }
    }

    private func header(for meal: Meal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(meal.name)
                .font(.largeTitle.bold())

            HStack(spacing: 8) {
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
        }
    }

    private func ingredientsSection(for meal: Meal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("detail.ingredients".localized)
                    .font(.title2.bold())
                Spacer()
                Text("detail.ingredients.count".localized(with: meal.ingredients.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Les ingrédients apparaissent un par un (animation décalée)
            ForEach(Array(meal.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(.tint)
                    Text(ingredient.name)
                    Spacer()
                    Text(ingredient.measure)
                        .foregroundStyle(.secondary)
                }
                .opacity(showIngredients ? 1 : 0)
                .offset(y: showIngredients ? 0 : 12)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05),
                    value: showIngredients
                )
            }
        }
    }

    @ViewBuilder
    private func instructionsSection(for meal: Meal) -> some View {
        if let instructions = meal.instructions {
            VStack(alignment: .leading, spacing: 12) {
                Text("detail.instructions".localized)
                    .font(.title2.bold())
                Text(instructions)
                    .font(.body)
                    .lineSpacing(4)
            }
        }
    }
}

private struct TagView: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.15), in: Capsule())
            .foregroundStyle(.tint)
    }
}

#Preview {
    NavigationStack {
        MealDetailView(meal: .preview)
    }
}
