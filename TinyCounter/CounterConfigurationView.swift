//
//  CounterConfigurationView.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//


import SwiftUI



struct CounterConfigurationView: View {
    @Binding var counter: CounterModel
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // ✨ Live updating name preview
                Text(counter.title.isEmpty ? "Unnamed Counter" : counter.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top)

                Form {
                    Section(header: Text("Counter Name")) {
                        TextField("Enter counter name", text: $counter.title)
                            .disableAutocorrection(true)
                            .autocapitalization(.sentences) // Or .words if you prefer
                    }

                    Section(header: Text("Counting Interval")) {
                        Stepper("Interval: \(counter.interval)", value: $counter.interval, in: 1...100)
                            .disabled(!store.isPremium)
                    }

                    if !store.isPremium {
                        Section {
                            Text("Changing the interval is a premium feature.")
                                .foregroundColor(.red)

                            Button("Upgrade to Premium") {
                                dismiss()
                                NotificationCenter.default.post(name: .showPaywall, object: nil)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Counter Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}


