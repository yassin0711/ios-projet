import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

/// Favoris de l'utilisateur, stockés dans Cloud Firestore : users/{uid}/favorites/{idRecette}
final class FavoritesService: ObservableObject {
    @Published private(set) var favorites: [Meal] = []

    private var listener: ListenerRegistration?

    /// Collection des favoris de l'utilisateur connecté (nil si personne n'est connecté)
    private var collection: CollectionReference? {
        guard FirebaseApp.app() != nil, let uid = Auth.auth().currentUser?.uid else { return nil }
        return Firestore.firestore().collection("users").document(uid).collection("favorites")
    }

    /// Écoute les favoris en temps réel : la liste se met à jour toute seule (chapitre 5)
    func startListening() {
        favorites = []
        listener?.remove()
        listener = collection?.addSnapshotListener { [weak self] snapshot, _ in
            self?.favorites = snapshot?.documents.map { document in
                let data = document.data()
                let area = data["area"] as? String ?? ""
                return Meal(
                    id: document.documentID,
                    name: data["name"] as? String ?? "",
                    thumbnailURL: URL(string: data["thumbnail"] as? String ?? ""),
                    category: nil,
                    area: area.isEmpty ? nil : area,
                    instructions: nil,
                    youtubeURL: nil,
                    tags: [],
                    ingredients: []
                )
            } ?? []
        }
    }

    func isFavorite(_ meal: Meal) -> Bool {
        favorites.contains { $0.id == meal.id }
    }

    func toggle(_ meal: Meal) {
        guard let document = collection?.document(meal.id) else { return }
        if isFavorite(meal) {
            document.delete()
        } else {
            document.setData([
                "name": meal.name,
                "thumbnail": meal.thumbnailURL?.absoluteString ?? "",
                "area": meal.area ?? "",
            ])
        }
    }
}
