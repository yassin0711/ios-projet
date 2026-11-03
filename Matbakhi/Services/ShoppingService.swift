import FirebaseFirestore

/// Un article de la liste de courses
struct ShoppingItem: Identifiable {
    let id: String
    let name: String
    let measure: String
    let done: Bool
}

/// Liste de courses dans Firestore : users/{uid}/shopping/{idArticle}
final class ShoppingService: ObservableObject {
    @Published private(set) var items: [ShoppingItem] = []

    private var listener: ListenerRegistration?

    func startListening() {
        items = []
        listener?.remove()
        listener = userCollection("shopping")?.order(by: "name").addSnapshotListener { [weak self] snapshot, _ in
            self?.items = snapshot?.documents.map { document in
                let data = document.data()
                return ShoppingItem(
                    id: document.documentID,
                    name: data["name"] as? String ?? "",
                    measure: data["measure"] as? String ?? "",
                    done: data["done"] as? Bool ?? false
                )
            } ?? []
        }
    }

    /// Ajoute un article (formulaire « Ajouter un article »)
    func addItem(name: String, measure: String) {
        userCollection("shopping")?.addDocument(data: ["name": name, "measure": measure, "done": false])
    }

    /// Ajoute tous les ingrédients d'une recette à la liste
    func add(_ ingredients: [Ingredient]) {
        for ingredient in ingredients {
            addItem(name: ingredient.name, measure: ingredient.measure)
        }
    }

    /// Coche ou décoche un article
    func toggle(_ item: ShoppingItem) {
        userCollection("shopping")?.document(item.id).updateData(["done": !item.done])
    }

    func delete(_ item: ShoppingItem) {
        userCollection("shopping")?.document(item.id).delete()
    }

    /// Supprime les articles déjà achetés (cochés)
    func clearDone() {
        for item in items where item.done {
            delete(item)
        }
    }
}
