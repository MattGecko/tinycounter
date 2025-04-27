//
//  PaywallView.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//


import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("🎉 Go Premium")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("Unlock themes, pre-made counters, color packs, and remove ads.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // Products
                    ForEach(store.products.sorted(by: { $0.price < $1.price }), id: \.id) { product in
                        Button(action: {
                            Task {
                                await store.purchase(product)
                                dismiss()
                            }
                        }) {
                            HStack {
                                Text("Buy \(product.displayName)")
                                Spacer()
                                Text(product.displayPrice)
                            }
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }

                    // Restore
                    Button("Restore Purchases") {
                        Task {
                            await store.restore()
                            dismiss()
                        }
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 10)

                    Divider().padding(.vertical)

                    // Links
                    VStack(spacing: 8) {
                        Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                        Link("Terms & Conditions", destination: URL(string: "https://example.com/terms")!)
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
