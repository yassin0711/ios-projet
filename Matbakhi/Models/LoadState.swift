/// Les états d'un écran qui charge des données (enum vue au chapitre 1)
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case failed(Error)
}
