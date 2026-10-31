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
            HomeSkeletonView()
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
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)

                    if let featured = home.featured {
                        FeaturedMealCard(meal: featured)
                    }
                    if !home.categories.isEmpty {
                        categoriesSection(home.categories)
                    }
                    if !home.tunisianMeals.isEmpty {
                        tunisianSection(home.tunisianMeals)
                    }
                }
                .padding()
            }
            .refreshable { await viewModel.load(isRefresh: true) }
            .transition(.opacity)
        }
    }

    private func categoriesSection(_ categories: [MealCategory]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "home.categories".localized)
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
                SectionHeader(title: "home.tunisian".localized)
                Spacer()
                NavigationLink("home.seeAll".localized, value: MealListSource.area("Tunisian"))
                    .font(.subheadline.weight(.semibold))
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(meals) { meal in
                        NavigationLink(value: meal) {
                            MealCard(meal: meal, height: 130)
                                .frame(width: 160)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
            }
        }
    }
}

// MARK: - Sous-vues de l'accueil

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2.bold())
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

                LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)

                VStack(alignment: .leading, spacing: 6) {
                    Label("home.featured".localized, systemImage: "sparkles")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial, in: Capsule())
                    Text(meal.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.leading)
                    if let area = meal.area {
                        Text(area)
                            .font(.subheadline)
                            .opacity(0.9)
                    }
                }
                .foregroundStyle(.white)
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

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
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(width: 92, height: 92)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview { HomeView() }
