import Foundation

/// Traduction dans la langue choisie DANS l'app (et non celle du téléphone).
/// Les textes sont dans Resources/<langue>.lproj/Localizable.strings.
enum L10n {
    private static let bundles: [AppLanguage: Bundle] = Dictionary(
        uniqueKeysWithValues: AppLanguage.allCases.map { language in
            let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj")
            return (language, path.flatMap { Bundle(path: $0) } ?? .main)
        }
    )

    static func string(_ key: String) -> String {
        let bundle = bundles[AppLanguage.current] ?? .main
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}

extension String {
    /// "tab.home".localized → « Accueil » / "Home" / « الرئيسية »
    var localized: String { L10n.string(self) }

    /// Pour les textes avec paramètres : "search.empty.message".localized(with: "pizza")
    func localized(with arguments: CVarArg...) -> String {
        String(format: L10n.string(self), locale: AppLanguage.current.locale, arguments: arguments)
    }
}
