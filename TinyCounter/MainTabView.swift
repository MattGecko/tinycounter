//
//  MainTabView.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//


import SwiftUI
import GoogleMobileAds
import StoreKit



struct MainTabView: View {
    @State private var actualTab = 0
    @State private var showToast = false
    @State private var toastMessage = "Counter Saved"
    @State private var selectedTabIntent = 0
    @EnvironmentObject var store: Store
    @EnvironmentObject var themeManager: ThemeManager
    


    var body: some View {
        ZStack {
            TabView(selection: $actualTab) {
                ContentView(selectedTab: $actualTab)
                    .tabItem { Label("Counter", systemImage: "plusminus") }
                    .tag(0)

                SavedCountersView(selectedTab: $actualTab)
                    .tabItem { Label("Saved", systemImage: "tray.full") }
                    .tag(1)

                ThemePickerView()
                    .tabItem { Label("Themes", systemImage: "paintbrush") }
                    .tag(2)
                
                CountdownsView()
                    .environmentObject(store)
                    .environmentObject(themeManager)
                    .tabItem { Label("Countdowns", systemImage: "hourglass") }
                    .tag(3)

            }

            if showToast {
                VStack {
                    Text(toastMessage)
                        .font(.caption)
                        .padding(10)
                        .background(Color.black.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .padding(.top, 30)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showToast)

        // Intercept the user's tab selection intent
        .onChange(of: selectedTabIntent) { newValue in
            if actualTab == 0 && newValue != actualTab {
                // If leaving the Counter tab, save and show toast first
                NotificationCenter.default.post(name: .saveCurrentCounter, object: nil)
                NotificationCenter.default.post(name: .showToast, object: "Counter Saved")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    actualTab = newValue
                }
            } else {
                actualTab = newValue
            }
        }

        // Listen for any toast requests
        .onReceive(NotificationCenter.default.publisher(for: .showToast)) { notif in
            toastMessage = notif.object as? String ?? "Counter Saved"
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showToast = false
                }
            }
        }
    }
}
