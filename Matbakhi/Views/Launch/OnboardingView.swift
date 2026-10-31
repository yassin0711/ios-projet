import SwiftUI

private struct OnboardingPage {
    let systemImage: String
    let titleKey: String
    let textKey: String
}

/// Présentation de l'app au premier lancement (3 pages)
struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(systemImage: "fork.knife", titleKey: "onboarding.1.title", textKey: "onboarding.1.text"),
        OnboardingPage(systemImage: "calendar", titleKey: "onboarding.2.title", textKey: "onboarding.2.text"),
        OnboardingPage(systemImage: "person.3.fill", titleKey: "onboarding.3.title", textKey: "onboarding.3.text"),
    ]

    private var isLastPage: Bool { currentPage == pages.count - 1 }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("onboarding.skip".localized, action: onFinish)
                    .opacity(isLastPage ? 0 : 1)
                    .animation(.easeInOut, value: isLastPage)
            }
            .padding()

            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index], isActive: currentPage == index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if isLastPage {
                    onFinish()
                } else {
                    withAnimation { currentPage += 1 }
                }
            } label: {
                Text(isLastPage ? "onboarding.start".localized : "onboarding.next".localized)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: page.systemImage)
                .font(.system(size: 90))
                .foregroundStyle(.tint)
                .symbolEffect(.bounce, value: isActive)
                .scaleEffect(isActive ? 1 : 0.6)
                .opacity(isActive ? 1 : 0.3)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isActive)

            Text(page.titleKey.localized)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(page.textKey.localized)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

#Preview { OnboardingView {} }
