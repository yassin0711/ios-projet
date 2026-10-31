import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("tab.home".localized)
                .mealNavigationDestinations()
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
        case .failed(let messageKey):
            ErrorStateView(messageKey: messageKey) {
                Task { await viewModel.load() }
            }
        case .empty:
            EmptyStateView(
                systemImage: "fork.knife",
                title: "state.empty.title".localized,
                message: "state.empty.message".localized
            )
        case .loaded(let home):
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("home.greeting".localized)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    if let featured = home.featured {
                        FeaturedMealCard(meal: featured)
                    }

                    categoriesSection(home.categories)

                    if !home.tunisianMeals.isEmpty {
                        tunisianSection(home.tunisianMeals)
                    }
                }
                .padding()
            }
        }
    }

    private func categoriesSection(_ categories: [MealCategory]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("home.categories".localized)
                .font(.title2.bold())

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories) { category in
                        NavigationLink(value: MealListSource.category(category.name)) {
                            CategoryChip(category: category)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
            }
        }
    }

    private func tunisianSection(_ meals: [Meal]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("home.tunisian".localized)
                    .font(.title2.bold())
                Spacer()
                NavigationLink("home.seeAll".localized, value: MealListSource.area("Tunisian"))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(meals) { meal in
                        NavigationLink(value: meal) {
                            MealCard(meal: meal)
                                .frame(width: 160)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
            }
        }
    }
}

/// Grande carte « Recette du jour »
private struct FeaturedMealCard: View {
    let meal: Meal

    var body: some View {
        NavigationLink(value: meal) {
            ZStack(alignment: .bottomLeading) {
                RemoteImage(url: meal.thumbnailURL)
                    .frame(height: 230)
                    .frame(maxWidth: .infinity)

                LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .center, endPoint: .bottom)

                VStack(alignment: .leading, spacing: 4) {
                    Label("home.featured".localized, systemImage: "sparkles")
                        .font(.caption.bold())
                    Text(meal.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.leading)
                }
                .foregroundStyle(.white)
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Vignette d'une catégorie (image + nom)
private struct CategoryChip: View {
    let category: MealCategory

    var body: some View {
        VStack(spacing: 6) {
            AsyncImage(url: category.thumbnailURL) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 64, height: 48)

            Text(category.name)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .frame(width: 92, height: 92)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview { HomeView() }
