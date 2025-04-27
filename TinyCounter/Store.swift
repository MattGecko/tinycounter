//
//  Store.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//

import Foundation
import StoreKit

@MainActor
class Store: ObservableObject {
    @Published var isPremium: Bool = {
        let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter")
        return defaults?.bool(forKey: "isPremium") ?? false
    }()
    
    @Published var products: [Product] = []

    private let productIDs = [
        "tinycounter.lifetime",
        "tinycounter.weekly",
        "tinycounter.monthly",
        "tinycounter.annual"
    ]

    init() {
        Task {
            await requestProducts()
            await checkEntitlements()
        }
    }

    func requestProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("❌ Failed to fetch products: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    print("✅ Purchase verified: \(transaction.productID)")
                    setPremium(true)
                    await transaction.finish()
                case .unverified:
                    print("❌ Purchase unverified")
                }
            case .userCancelled:
                print("❌ User cancelled the purchase.")
            default:
                break
            }
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }

    func restore() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if productIDs.contains(transaction.productID) {
                    print("✅ Restored: \(transaction.productID)")
                    setPremium(true)
                }
            default:
                break
            }
        }
    }

    private func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if productIDs.contains(transaction.productID) {
                    setPremium(true)
                }
            default:
                break
            }
        }
    }

    private func setPremium(_ value: Bool) {
        if let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter") {
            defaults.set(value, forKey: "isPremium")
        }
        isPremium = value
    }
}
