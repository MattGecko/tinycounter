// TinyCounterApp.swift
import SwiftUI
import GoogleMobileAds
import StoreKit


struct ContentView: View {
    @State private var showingSettings = false
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("selectedCounterId") private var selectedCounterId = ""
    @EnvironmentObject var store: Store
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int

    @State private var showingPaywall = false
    @AppStorage("totalTaps") private var totalTaps = 0

    @State private var counter: CounterModel =
        .init(id: UUID(),
              title: "My Counter",
              count: 0,
              totalTaps: 0,
              createdDate: Date(),
              religious: false,
              interval: 1)
    
  //  @Environment(\.colorScheme) private var colorScheme

    func colorForTitle() -> Color {
        let background = themeManager.selectedTheme.background
        let brightness = (background.red * 299 + background.green * 587 + background.blue * 114) / 1000

        if brightness > 0.7 {
            // Light background (e.g., white, lemon yellow)
            return .black
        } else {
            // Dark background (e.g., midnight, galaxy)
            return .white
        }
    }


    var body: some View {
        NavigationView {
            ZStack {
                // fill the full background
                themeManager.selectedTheme.background.swiftUIColor
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("Counter Name", text: $counter.title)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundColor(colorForTitle())
                        .padding(.horizontal)

                    Text("\(counter.count)")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 200, minHeight: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeGradient())
                                .shadow(radius: 10)
                        )

                    HStack(spacing: 40) {
                        Button { updateCount(by: -1) } label: {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                        }

                        Button("Reset") { resetCount() }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)

                        Button { updateCount(by: 1) } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                        }
                    }

                    Button("Save") {
                        saveCounter()
                        // only toast here
                        NotificationCenter.default.post(name: .showToast, object: "Counter Saved")
                    }
                    .padding()
                    .background(themeManager.selectedTheme.primary.swiftUIColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Spacer()

                    if !store.isPremium {
                        BannerAdView()
                            .frame(height: 50)
                    }
                }
                .padding()
            }
            .onAppear { loadSelectedCounter() }

            // save when MainTabView tells us (on tab change)
            .onReceive(NotificationCenter.default.publisher(for: .saveCurrentCounter)) { _ in
                saveCounter()
            }

            // save when going to background
            .onChange(of: scenePhase) { phase in
                if phase == .background || phase == .inactive {
                    saveCounter()
                    NotificationCenter.default.post(name: .showToast, object: "Counter Saved")
                }
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Settings") { showingSettings = true }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Upgrade") { showingPaywall = true }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(showingPaywall: $showingPaywall, counter: $counter)
            }
            .onReceive(NotificationCenter.default.publisher(for: .showPaywall)) { _ in
                showingPaywall = true
            }
            .onChange(of: selectedCounterId) { _ in
                loadSelectedCounter()
            }
        }
    }

    // MARK: - Counter Logic

    func updateCount(by direction: Int) {
        counter.count += direction * counter.interval
        counter.totalTaps += 1  
        totalTaps += 1
        Haptics.tap()

        if !store.isPremium && totalTaps % 30 == 0 {
            if let root = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first {
                AdManager.shared.showAd(from: root)
            }
        }
    }

    func resetCount() {
        counter.count = 0
        Haptics.tap()
    }

    func saveCounter() {
        var saved = loadSavedCounters()
        if let idx = saved.firstIndex(where: { $0.id == counter.id }) {
            saved[idx] = counter
        } else {
            saved.append(counter)
        }
        if let data = try? JSONEncoder().encode(saved),
           let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter") {
            defaults.set(data, forKey: "savedCounters")
        }
        Haptics.tap()
        // **DO NOT** repost .saveCurrentCounter here or you'll recurse!
    }

    func loadSavedCounters() -> [CounterModel] {
        if let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter"),
           let data = defaults.data(forKey: "savedCounters"),
           let decoded = try? JSONDecoder().decode([CounterModel].self, from: data) {
            return decoded
        } else {
            return []
        }
    }


    func loadSelectedCounter() {
        let all = loadSavedCounters()
        if let found = all.first(where: { $0.id.uuidString == selectedCounterId }) {
            counter = found
        }
    }

    func themeGradient() -> LinearGradient {
        LinearGradient(
            colors: [
                themeManager.selectedTheme.primary.swiftUIColor,
                .blue
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension Notification.Name {
    static let showPaywall         = Notification.Name("showPaywall")
    static let saveCurrentCounter  = Notification.Name("saveCurrentCounter")
    static let showToast           = Notification.Name("showToast")
}






