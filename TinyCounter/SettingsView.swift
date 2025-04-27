import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss

    @Binding var showingPaywall: Bool
    @Binding var counter: CounterModel

    @State private var showingCounterConfig = false
    @State private var showingUpgradePrompt = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Premium")) {
                    Button("Restore Purchases") {
                        Task { await store.restore() }
                    }
                    Button("Upgrade to Premium") {
                        // 1) Close Settings first...
                        dismiss()
                        // 2) ...then ask the parent to show the paywall
                        DispatchQueue.main.async {
                            showingPaywall = true
                        }
                    }
                }

                Section(header: Text("Active Counter")) {
                    Button("Change Interval") {
                        if store.isPremium {
                            showingCounterConfig = true
                        } else {
                            showingUpgradePrompt = true
                        }
                    }
                }

                Section(header: Text("Theme")) {
                    NavigationLink("Choose Theme") {
                        ThemePickerTab()
                    }
                }

                Section(header: Text("Info")) {
                    Text("Version: 1.0")
                    Text("Made with ❤️ by Doug and Matt")
                }

                Section {
                    Button("Reset Onboarding") {
                        if let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter") {
                            defaults.set(false, forKey: "hasSeenOnboarding")
                        }
                        dismiss()
                    }

                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
        // only these two stay here:
        .sheet(isPresented: $showingCounterConfig) {
            CounterConfigurationView(counter: $counter)
        }
        .alert("Premium Feature", isPresented: $showingUpgradePrompt) {
            Button("Upgrade") {
                dismiss()
                DispatchQueue.main.async {
                    showingPaywall = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Changing intervals is a premium feature.")
        }
    }
}

