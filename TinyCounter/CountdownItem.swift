//
//  CountdownItem.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//


import SwiftUI

struct CountdownsView: View {
    @State private var countdowns: [CountdownItem] = []
    @State private var selectedCountdown: CountdownItem?
    @State private var showAddCountdown = false
    @EnvironmentObject var store: Store
    @EnvironmentObject var themeManager: ThemeManager
    @State private var now = Date()
    @State private var isCapturing = false
    @State private var editingCountdown: CountdownItem? = nil
    @State private var showEditSheet = false




    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // TOP HALF
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        if let data = selectedCountdown?.imageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        } else {
                            themeManager.selectedTheme.background.swiftUIColor
                                .opacity(0.2)
                        }

                        VStack(spacing: 12) {
                            Text(selectedCountdown?.title ?? "No Countdown Selected")
                                .font(.title)
                                .bold()
                                .foregroundColor(themeManager.selectedTheme.text.swiftUIColor)
                                .padding(.top)

                            if let target = selectedCountdown?.targetDate {
                                CountdownTimerView(targetDate: target, now: now)
                            }
                        }
                        .padding()
                        .background(themeManager.selectedTheme.primary.swiftUIColor.opacity(0.7))
                        .cornerRadius(12)
                        .padding()
                    }
                    .frame(height: 300)

                    if !isCapturing {
                        Button(action: shareCountdown) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20, weight: .bold)) // Smaller and bold
                                .foregroundColor(.white)                // Pure white icon
                                .padding(12)                            // Light padding for easier tapping
                        }
                        .padding([.bottom, .trailing], 16)              // Neatly tucked in the bottom-right
                    }

                }
                
                // BOTTOM HALF
                Form {
                    Section {
                        Button("Add New Countdown") {
                            if store.isPremium || countdowns.count < 1 {
                                showAddCountdown = true
                            } else {
                               
                                NotificationCenter.default.post(name: .showPaywall, object: nil)
                            }
                        }

                    }
                    
                    Section(header: Text("Saved Countdowns")) {
                        ForEach(countdowns) { countdown in
                            Button(action: {
                                selectedCountdown = countdown
                            }) {
                                VStack(alignment: .leading) {
                                    Text(countdown.title)
                                    Text(countdown.targetDate, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .swipeActions(edge: .leading) { // ← swipe right
                                Button("Edit") {
                                    editCountdown(countdown)
                                }
                                .tint(.blue)
                            }
                        }
                        .onDelete(perform: deleteCountdowns)
                    }

                }
            }
            .navigationTitle("Countdowns")
        }

        .sheet(isPresented: $showAddCountdown) {
            AddCountdownView(countdowns: $countdowns, selectedCountdown: $selectedCountdown)
                .environmentObject(store)

        }
        .sheet(isPresented: $showEditSheet) {
            if let countdown = editingCountdown {
                AddCountdownView(
                    countdowns: $countdowns,
                    selectedCountdown: $selectedCountdown,
                    editingCountdown: countdown
                )
                .environmentObject(store)
            }
        }

        .onAppear {
            loadCountdowns()
            startTimer()
        }

    }
    
    func editCountdown(_ countdown: CountdownItem) {
        editingCountdown = countdown
        showEditSheet = true
    }

    
    func shareCountdown() {
        isCapturing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let image = ZStack {
                if let data = selectedCountdown?.imageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    themeManager.selectedTheme.background.swiftUIColor.opacity(0.2)
                }

                VStack(spacing: 12) {
                    Text(selectedCountdown?.title ?? "No Countdown Selected")
                        .font(.title)
                        .bold()
                        .foregroundColor(themeManager.selectedTheme.text.swiftUIColor)
                        .padding(.top)

                    if let target = selectedCountdown?.targetDate {
                        CountdownTimerView(targetDate: target, now: now)
                    }
                }
                .padding()
                .background(themeManager.selectedTheme.primary.swiftUIColor.opacity(0.7))
                .cornerRadius(12)
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width, height: 300)
            .snapshot()

            isCapturing = false

            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(activityVC, animated: true)
            }
        }
    }


    
    func loadCountdowns() {
        if let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter"),
           let data = defaults.data(forKey: "savedCountdowns"),
           let decoded = try? JSONDecoder().decode([CountdownItem].self, from: data) {
            countdowns = decoded.sorted(by: { $0.targetDate < $1.targetDate })
            selectedCountdown = countdowns.first
        }
    }

    func deleteCountdowns(at offsets: IndexSet) {
        offsets.forEach { index in
            let removed = countdowns[index]
            if selectedCountdown?.id == removed.id {
                selectedCountdown = nil
            }
        }
        countdowns.remove(atOffsets: offsets)
        saveCountdowns()
    }

    func saveCountdowns() {
        if let data = try? JSONEncoder().encode(countdowns),
           let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter") {
            defaults.set(data, forKey: "savedCountdowns")
        }
    }


    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            now = Date()
        }
    }
    
    


}



extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
