import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject private var shopping: ShoppingService
    @State private var showAddItem = false

    var body: some View {
        Group {
            if shopping.items.isEmpty {
                ContentUnavailableView("shopping.empty.title".localized, systemImage: "cart",
                                       description: Text("shopping.empty.message".localized))
            } else {
                List {
                    ForEach(shopping.items) { item in
                        Button {
                            shopping.toggle(item)
                        } label: {
                            HStack {
                                Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.done ? Color.green : Color.secondary)
                                    .contentTransition(.symbolEffect(.replace))
                                Text(item.name)
                                    .strikethrough(item.done)
                                Spacer()
                                Text(item.measure)
                                    .foregroundStyle(.secondary)
                            }
                            // Animation quand on coche : l'icône change et le texte se barre
                            .animation(.default, value: item.done)
                        }
                        .foregroundStyle(.primary)
                    }
                    // Glisser vers la gauche pour supprimer un article
                    .onDelete { offsets in
                        for index in offsets {
                            shopping.delete(shopping.items[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("shopping.title".localized)
        .toolbar {
            Button("shopping.clearDone".localized) {
                shopping.clearDone()
            }
            .disabled(!shopping.items.contains { $0.done })

            // Bouton + : ouvre le formulaire dans une feuille qui monte du bas
            Button {
                showAddItem = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddItemView()
                .presentationDetents([.medium])   // la feuille couvre la moitié de l'écran
        }
    }
}

#Preview {
    NavigationStack {
        ShoppingListView()
            .environmentObject(ShoppingService())
    }
}
