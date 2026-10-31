import SwiftUI

/// Carte d'une recette : image, nom, pays ou catégorie
struct MealCard: View {
    let meal: Meal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RemoteImage(url: meal.thumbnailURL)
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(meal.name)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)

            if let subtitle = meal.area ?? meal.category {
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
            .animation(.spring(), value: configuration.isPressed)
    }
}

#Preview {
    MealCard(meal: .preview)
        .frame(width: 180)
        .padding()
}
