import FirebaseFirestore

/// Jours de la semaine du planning. rawValue sert d'identifiant du document Firestore
enum WeekDay: String, CaseIterable, Identifiable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: String { rawValue }

    /// Clé du texte traduit, par exemple "day.monday"
    var titleKey: String { "day.\(rawValue)" }
}

/// Planning de la semaine dans Firestore : users/{uid}/planning/{jour} → la recette prévue ce jour-là
final class PlanningService: ObservableObject {
    @Published private(set) var meals: [WeekDay: Meal] = [:]

    private var listener: ListenerRegistration?

    func startListening() {
        meals = [:]
        listener?.remove()
        listener = userCollection("planning")?.addSnapshotListener { [weak self] snapshot, _ in
            var planned: [WeekDay: Meal] = [:]
            for document in snapshot?.documents ?? [] {
                if let day = WeekDay(rawValue: document.documentID) {
                    let data = document.data()
                    planned[day] = Meal(id: data["mealId"] as? String ?? "", firestoreData: data)
                }
            }
            self?.meals = planned
        }
    }

    func plan(_ meal: Meal, on day: WeekDay) {
        var data = meal.firestoreData
        data["mealId"] = meal.id
        userCollection("planning")?.document(day.rawValue).setData(data)
    }

    func remove(_ day: WeekDay) {
        userCollection("planning")?.document(day.rawValue).delete()
    }
}
