import SwiftUI

struct SavedCountersView: View {
    @AppStorage("selectedCounterId") private var selectedCounterId = ""
    @State private var showPresetPicker = false
    @State private var counters: [CounterModel] = []
    @State private var showLimitAlert = false
    @State private var selectedCounterForConfig: CounterModel?
    @Binding var selectedTab: Int

    @EnvironmentObject var store: Store

    let presetCounters: [CounterModel] = [
        .init(id: UUID(), title: "Water Intake 💧", count: 0, totalTaps: 0, createdDate: Date(), religious: false, interval: 1),
        .init(id: UUID(), title: "Pushups 💪", count: 0, totalTaps: 0, createdDate: Date(), religious: false, interval: 1),
        .init(id: UUID(), title: "Steps 👣", count: 0, totalTaps: 0, createdDate: Date(), religious: false, interval: 1),
        .init(id: UUID(), title: "Meetings 📅", count: 0, totalTaps: 0, createdDate: Date(), religious: false, interval: 1),
        .init(id: UUID(), title: "Prayers 🙏", count: 0, totalTaps: 0, createdDate: Date(), religious: true, interval: 1),
        .init(id: UUID(), title: "Sutras 🕉️", count: 0, totalTaps: 0, createdDate: Date(), religious: true, interval: 1)
    ]

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(counters) { counter in
                        Button(action: {
                            selectedCounterId = counter.id.uuidString
                            selectedTab = 0
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(counter.title)
                                        .font(.headline)
                                    Text("\(counter.count) (\(counter.totalTaps) taps)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Button {
                                    if store.isPremium {
                                        selectedCounterForConfig = counter
                                    } else {
                                        showLimitAlert = true
                                    }
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete(perform: delete)
                }

                Button(action: addNewCounter) {
                    Label("New Counter", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom)

                Button(action: {
                    showPresetPicker = true
                }) {
                    Label("Load Preset", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Saved Counters")
            .onAppear(perform: loadCounters)
            .alert("Limit Reached", isPresented: $showLimitAlert) {
                Button("Upgrade") {
                    NotificationCenter.default.post(name: .showPaywall, object: nil)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Upgrade to Premium to save more than 2 counters or configure advanced options.")
            }
        }
        .actionSheet(isPresented: $showPresetPicker) {
            ActionSheet(
                title: Text("Choose a Preset"),
                buttons:
                    presetCounters.map { preset in
                        .default(Text(preset.title)) {
                            addPreset(preset)
                        }
                    } + [.cancel()]
            )
        }
        .sheet(item: $selectedCounterForConfig) { counter in
            CounterConfigurationView(counter: binding(for: counter))
        }
        .onAppear(perform: loadCounters)
        .onReceive(NotificationCenter.default.publisher(for: .saveCurrentCounter)) { _ in
            loadCounters()
        }
    }

    // MARK: - Data helpers

    private func loadCounters() {
        if let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter"),
           let data = defaults.data(forKey: "savedCounters"),
           let decoded = try? JSONDecoder().decode([CounterModel].self, from: data) {
            counters = decoded
        } else {
            counters = []
        }
    }

    func addPreset(_ preset: CounterModel) {
        guard store.isPremium || counters.count < 2 else {
            showLimitAlert = true
            return
        }
        var copy = preset
        copy.id = UUID()
        copy.createdDate = Date()
        counters.append(copy)
        save()
        selectedCounterId = copy.id.uuidString
        selectedTab = 0
    }

    func addNewCounter() {
        guard store.isPremium || counters.count < 2 else {
            showLimitAlert = true
            return
        }
        let new = CounterModel(id: UUID(), title: "New Counter", count: 0, totalTaps: 0, createdDate: Date(), religious: false, interval: 1)
        counters.append(new)
        save()
        selectedCounterId = new.id.uuidString
        selectedTab = 0
    }

    func load() {
        if let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter"),
           let data = defaults.data(forKey: "savedCounters"),
           let decoded = try? JSONDecoder().decode([CounterModel].self, from: data) {
            counters = decoded
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(counters),
           let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter") {
            defaults.set(data, forKey: "savedCounters")
        }
    }

    func delete(at offsets: IndexSet) {
        counters.remove(atOffsets: offsets)
        save()
    }

    func binding(for counter: CounterModel) -> Binding<CounterModel> {
        guard let idx = counters.firstIndex(where: { $0.id == counter.id }) else {
            return .constant(counter)
        }
        return Binding(
            get: { counters[idx] },
            set: {
                counters[idx] = $0
                save()
            }
        )
    }
}
