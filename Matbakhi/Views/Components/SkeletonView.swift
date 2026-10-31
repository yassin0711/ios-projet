import SwiftUI

/// Squelette de l'accueil pendant le chargement (formes grises qui « respirent »)
struct HomeSkeletonView: View {
    @State private var isDimmed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                block(height: 220)
                block(height: 20).frame(width: 140)
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { _ in
                        block(height: 90).frame(width: 90)
                    }
                }
                block(height: 20).frame(width: 180)
                HStack(spacing: 12) {
                    block(height: 180)
                    block(height: 180)
                }
            }
            .padding()
        }
        .scrollDisabled(true)
        .opacity(isDimmed ? 0.4 : 1)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isDimmed)
        .onAppear { isDimmed = true }
        .accessibilityLabel("state.loading".localized)
    }

    private func block(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray5))
            .frame(height: height)
    }
}

#Preview { HomeSkeletonView() }
