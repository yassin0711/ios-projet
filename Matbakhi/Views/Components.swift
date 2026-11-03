import SwiftUI

// Petites vues réutilisées par plusieurs écrans.
// Pour les états vides, on utilise directement ContentUnavailableView (vue native d'iOS 17).

/// Indicateur de chargement natif + petite poêle animée
struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "frying.pan.fill")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
                .symbolEffect(.pulse)
            ProgressView("state.loading".localized)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Message d'erreur clair + bouton « Réessayer »
struct ErrorStateView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("state.error.title".localized, systemImage: "wifi.exclamationmark")
        } description: {
            Text(((error as? NetworkError)?.messageKey ?? "error.unknown").localized)
        } actions: {
            Button("state.retry".localized, action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}

/// Grille de recettes sur 2 colonnes (LazyVGrid : les cartes sont créées au fil du défilement)
struct MealGrid: View {
    let meals: [Meal]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
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

/// Image téléchargée depuis une URL, qui apparaît en fondu
struct RemoteImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeIn)) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else {
                Color(.secondarySystemBackground)   // fond gris pendant le chargement
            }
        }
    }
}

/// Champ de formulaire avec son message d'erreur en dessous (bordure rouge si erreur)
struct FormField: View {
    let titleKey: String
    @Binding var text: String
    var isSecure = false
    var errorKey: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                if isSecure {
                    SecureField(titleKey.localized, text: $text)
                } else {
                    TextField(titleKey.localized, text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorKey == nil ? Color.clear : Color.red)
            )

            if let errorKey {
                Text(errorKey.localized)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview("Carte") {
    MealCard(meal: .preview)
        .frame(width: 180)
        .padding()
}

#Preview("Champ") {
    FormField(titleKey: "auth.email", text: .constant("ali"), errorKey: "validation.email")
        .padding()
}
