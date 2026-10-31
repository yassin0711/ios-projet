import SwiftUI

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
    let messageKey: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("state.error.title".localized, systemImage: "wifi.exclamationmark")
        } description: {
            Text(messageKey.localized)
        } actions: {
            Button("state.retry".localized, action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}

/// État vide : rien à afficher (aucun résultat, liste vide...)
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage, description: Text(message))
    }
}

#Preview("Chargement") { LoadingStateView() }
#Preview("Erreur") { ErrorStateView(messageKey: "error.network.offline") {} }
#Preview("Vide") {
    EmptyStateView(systemImage: "magnifyingglass", title: "Aucun résultat", message: "Essayez un autre mot.")
}
