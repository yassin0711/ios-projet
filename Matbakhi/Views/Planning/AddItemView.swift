import SwiftUI

/// Formulaire « Ajouter un article » à la liste de courses (affiché dans une feuille)
struct AddItemView: View {
    @EnvironmentObject private var shopping: ShoppingService
    @Environment(\.dismiss) private var dismiss   // pour fermer la feuille

    @State private var name = ""
    @State private var quantity = ""
    @State private var showErrors = false   // les erreurs s'affichent après le premier essai

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                FormField(titleKey: "shopping.item.name", text: $name,
                          errorKey: showErrors ? Validation.name(name) : nil)

                FormField(titleKey: "shopping.item.quantity", text: $quantity)

                Button {
                    save()
                } label: {
                    Text("shopping.item.add".localized)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Spacer()
            }
            .padding()
            .navigationTitle("shopping.add".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) { dismiss() }
                }
            }
        }
    }

    private func save() {
        showErrors = true
        guard Validation.name(name) == nil else { return }   // nom invalide : rien n'est enregistré

        shopping.addItem(name: name.trimmingCharacters(in: .whitespaces), measure: quantity)
        dismiss()
    }
}

#Preview {
    AddItemView()
        .environmentObject(ShoppingService())
}
