//
//  TinyCounterApp.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//


import SwiftUI
import GoogleMobileAds
import StoreKit

@main
struct TinyCounterApp: App {
    @StateObject private var store = Store()
    @StateObject private var themeManager = ThemeManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    init() {
        MobileAds.shared.start(completionHandler: nil)
        AdManager.shared.loadAd()
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground // or .white

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

    }

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView()
                    .environmentObject(store)
                    .environmentObject(themeManager)
            } else {
                OnboardingView()
                    .environmentObject(store)
                    .environmentObject(themeManager)
            }
        }
    }
}