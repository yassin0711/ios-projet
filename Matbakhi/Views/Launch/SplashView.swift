import SwiftUI

/// Écran de lancement animé : le logo tourne et grossit, puis le slogan apparaît
struct SplashView: View {
    let onFinish: () -> Void

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 110))
                    .foregroundStyle(.white)
                    .scaleEffect(isAnimating ? 1 : 0.4)
                    .rotationEffect(.degrees(isAnimating ? 0 : -90))

                Text("app.name".localized)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("app.tagline".localized)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.85))
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
            }
        }
        .task {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                isAnimating = true
            }
            try? await Task.sleep(for: .seconds(1.6))
            onFinish()
        }
    }
}

#Preview { SplashView {} }
