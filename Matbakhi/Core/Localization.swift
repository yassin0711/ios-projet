import Foundation

extension String {
    /// Traduit la clé dans la langue choisie dans l'app :
    /// "tab.home".localized → « Accueil » / "Home" / « الرئيسية »
    /// Les textes sont dans Resources/<langue>.lproj/Localizable.strings
    var localized: String {
        let path = Bundle.main.path(forResource: AppLanguage.current.rawValue, ofType: "lproj")
        let bundle = path.flatMap { Bundle(path: $0) } ?? .main
        return bundle.localizedString(forKey: self, value: self, table: nil)
    }
}
