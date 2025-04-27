//
//  BannerAdView.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//


// BannerAdView.swift
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = "ca-app-pub-3785918208569837/1584659342" // Test ad unit ID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}