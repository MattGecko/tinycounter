import SwiftUI

struct AddCountdownView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var countdowns: [CountdownItem]
    @Binding var selectedCountdown: CountdownItem?

    var editingCountdown: CountdownItem? = nil

    @State private var title = ""
    @State private var targetDate = Date()
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Countdown Title")) {
                    TextField("Enter event name", text: $title)
                }

                Section(header: Text("Target Date")) {
                    DatePicker("Event Date", selection: $targetDate, displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Background Image (Optional)")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 150)
                    }

                    Button("Choose Image") {
                        showingImagePicker = true
                    }
                }
            }
            .navigationTitle(editingCountdown == nil ? "New Countdown" : "Edit Countdown")
            .onAppear {
                if let countdown = editingCountdown {
                    title = countdown.title
                    targetDate = countdown.targetDate
                    if let data = countdown.imageData {
                        selectedImage = UIImage(data: data)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCountdown()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }

    func saveCountdown() {
        if let editing = editingCountdown {
            // Update existing countdown
            if let index = countdowns.firstIndex(where: { $0.id == editing.id }) {
                countdowns[index].title = title
                countdowns[index].targetDate = targetDate
                countdowns[index].imageData = selectedImage?.jpegData(compressionQuality: 0.8)
            }
        } else {
            // Create new countdown
            let newCountdown = CountdownItem(
                id: UUID(),
                title: title,
                targetDate: targetDate,
                imageData: selectedImage?.jpegData(compressionQuality: 0.8)
            )
            countdowns.append(newCountdown)
            selectedCountdown = newCountdown
        }

        countdowns.sort(by: { $0.targetDate < $1.targetDate })

        if let data = try? JSONEncoder().encode(countdowns) {
            if let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter") {
                defaults.set(data, forKey: "savedCountdowns")
            }
        }
    }
}
