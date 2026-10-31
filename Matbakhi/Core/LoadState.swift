import Foundation

/// Les états d'un écran qui charge des données (enum vue au chapitre 1).
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    /// Clé de traduction du message d'erreur
    case failed(String)
}
