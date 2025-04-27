//
//  AdManager.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//


// AdManager.swift
import GoogleMobileAds

class AdManager: NSObject, FullScreenContentDelegate {
    static let shared = AdManager()
    private var interstitial: InterstitialAd?

    func loadAd() {
        let request = Request()
        InterstitialAd.load(
            with: "ca-app-pub-3785918208569837/3110569407", // ✅ Replace with your real one later
            request: request
        ) { [weak self] ad, error in
            if let ad = ad {
                self?.interstitial = ad
                ad.fullScreenContentDelegate = self
            } else {
                print("Failed to load interstitial: \(String(describing: error))")
            }
        }
    }

    func showAd(from root: UIViewController) {
        if let ad = interstitial {
            ad.present(from: root)
            interstitial = nil
            loadAd()
        } else {
            print("Ad not ready")
            loadAd()
        }
    }

    // Optional delegate methods
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad dismissed")
    }
}
