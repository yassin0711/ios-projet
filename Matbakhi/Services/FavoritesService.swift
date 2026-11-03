import FirebaseFirestore

/// Favoris de l'utilisateur, stockés dans Cloud Firestore : users/{uid}/favorites/{idRecette}
final class FavoritesService: ObservableObject {
    @Published private(set) var meals: [Meal] = []

    private var listener: ListenerRegistration?

    /// Écoute les favoris en temps réel : la liste se met à jour toute seule (chapitre 5)
    func startListening() {
        meals = []
        listener?.remove()
        listener = userCollection("favorites")?.addSnapshotListener { [weak self] snapshot, _ in
            self?.meals = snapshot?.documents.map { document in
                Meal(id: document.documentID, firestoreData: document.data())
            } ?? []
        }
    }

    func isFavorite(_ meal: Meal) -> Bool {
        meals.contains { $0.id == meal.id }
    }

    func toggle(_ meal: Meal) {
        guard let document = userCollection("favorites")?.document(meal.id) else { return }
        if isFavorite(meal) {
            document.delete()
        } else {
            document.setData(meal.firestoreData)
        }
    }
}
