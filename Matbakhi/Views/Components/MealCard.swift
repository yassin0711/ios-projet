import SwiftUI

/// Carte d'une recette (grilles et listes horizontales)
struct MealCard: View {
    let meal: Meal
    var height: CGFloat = 140

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RemoteImage(url: meal.thumbnailURL)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(meal.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)

            if let subtitle = [meal.area, meal.category].compactMap({ $0 }).first {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Animation au toucher : la carte rétrécit légèrement puis rebondit
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    MealCard(meal: .preview)
        .frame(width: 180)
        .padding()
}
