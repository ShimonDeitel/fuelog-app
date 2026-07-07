import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: FuelogEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                List {
                    if store.entries.isEmpty {
                        Text("No fill-ups yet. Tap + to add your first one.")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.textSecondary)
                            .listRowBackground(Color.clear)
                    }
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            row(for: entry)
                        }
                        .accessibilityIdentifier("entryRow_\(entry.id)")
                        .listRowBackground(AppTheme.card)
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Fuelog")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    if !store.add(newEntry) {
                        showPaywall = true
                    }
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .tint(AppTheme.accent)
    }

    @ViewBuilder
    private func row(for entry: FuelogEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.vehicleName)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.textPrimary)
                Text(entry.note)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(entry.date, style: .date)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Text(entry.amount, format: .currency(code: "USD"))
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.accent)
        }
        .padding(.vertical, 4)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: FuelogEntry?
    let onSave: (FuelogEntry) -> Void

    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var note: String = ""
    @State private var date: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle") {
                    TextField("Vehicle name", text: $name)
                        .accessibilityIdentifier("nameField")
                }
                Section("Amount") {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("amountField")
                }
                Section("Note") {
                    TextField("Note", text: $note)
                        .accessibilityIdentifier("noteField")
                }
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .dismissKeyboardOnTap()
            .navigationTitle(entry == nil ? "Add Fill-up" : "Edit Fill-up")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let amount = Double(amountText) ?? 0
                        var e = entry ?? FuelogEntry(vehicleName: name, amount: amount, note: note, date: date)
                        e.vehicleName = name
                        e.amount = amount
                        e.note = note
                        e.date = date
                        onSave(e)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear {
                if let entry {
                    name = entry.vehicleName
                    amountText = entry.amount == 0 ? "" : String(entry.amount)
                    note = entry.note
                    date = entry.date
                }
            }
        }
    }
}
