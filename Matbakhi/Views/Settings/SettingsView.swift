import SwiftUI

struct SettingsView: View {
    // Même clés que dans MatbakhiApp : changer la valeur ici met toute l'app à jour
    @AppStorage(AppTheme.storageKey) private var theme: AppTheme = .system
    @AppStorage(AppLanguage.storageKey) private var language: AppLanguage = .deviceDefault

    var body: some View {
        NavigationStack {
            Form {
                Section("settings.appearance".localized) {
                    Picker("settings.theme".localized, selection: $theme) {
                        ForEach(AppTheme.allCases) { option in
                            Label(option.titleKey.localized, systemImage: option.icon)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("settings.language".localized) {
                    Picker("settings.language".localized, selection: $language) {
                        ForEach(AppLanguage.allCases) { option in
                            Text(option.displayName)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("settings.about".localized) {
                    LabeledContent("settings.version".localized, value: appVersion)
                    LabeledContent("settings.api".localized, value: "TheMealDB")
                }
            }
            .navigationTitle("settings.title".localized)
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview { SettingsView() }
