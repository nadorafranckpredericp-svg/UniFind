import SwiftUI
import PhotosUI

struct AdminRegisterView: View {
    @EnvironmentObject private var itemController: ItemController
    @State private var reportType: ReportType = .found
    @State private var name = ""
    @State private var category = "Electronics"
    @State private var itemDescription = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isSaving = false
    @State private var message: String?
    @State private var showSuccess = false
    private let categories = ["Electronics", "Wallets", "IDs", "Bags", "Keys", "Clothing", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Record Type") {
                    Picker("Type", selection: $reportType) {
                        Text("Lost").tag(ReportType.lost)
                        Text("Found").tag(ReportType.found)
                    }.pickerStyle(.segmented)
                }
                Section("Item Information") {
                    TextField("Item name", text: $name)
                    Picker("Category", selection: $category) { ForEach(categories, id: \.self) { Text($0) } }
                    TextField("Location", text: $location)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Description", text: $itemDescription, axis: .vertical).lineLimit(3...6)
                }
                Section("Item Photo") {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(imageData == nil ? "Select Photo" : "Change Photo", systemImage: "photo")
                    }
                    if imageData != nil { Label("Photo ready for Cloudinary upload", systemImage: "checkmark.circle.fill").foregroundStyle(.green) }
                }
                if let message { Section { Text(message).foregroundStyle(.red) } }
                Section {
                    Button {
                        Task { await save() }
                    } label: {
                        HStack { Spacer(); if isSaving { ProgressView().tint(.white) } else { Text("Register Item").fontWeight(.semibold) }; Spacer() }
                    }
                    .disabled(!isValid || isSaving)
                    .listRowBackground(isValid ? Color.uniFindMaroon : Color.gray.opacity(0.35))
                    .foregroundStyle(.white)
                }
            }
            .scrollContentBackground(.hidden).background(Color.uniFindBackground)
            .navigationTitle("Register")
            .onChange(of: photoItem) { _, newValue in
                Task { imageData = try? await newValue?.loadTransferable(type: Data.self) }
            }
            .alert("Item Registered", isPresented: $showSuccess) {
                Button("OK") { clearForm() }
            } message: { Text("The official record was saved to Firestore successfully.") }
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !itemDescription.trimmingCharacters(in: .whitespaces).isEmpty
    }

    @MainActor private func save() async {
        isSaving = true; message = nil
        do {
            try await itemController.registerItem(name: name, category: category, description: itemDescription,
                location: location, date: date, reportType: reportType, imageData: imageData)
            showSuccess = true
        } catch { message = error.localizedDescription }
        isSaving = false
    }

    private func clearForm() {
        name = ""; category = "Electronics"; itemDescription = ""; location = ""; date = Date()
        photoItem = nil; imageData = nil; message = nil
    }
}
