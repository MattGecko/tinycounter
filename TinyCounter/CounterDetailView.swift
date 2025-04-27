//
//  CounterDetailView.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/22/25.
//


// CounterDetailView.swift
import SwiftUI

struct CounterDetailView: View {
    @State var counter: CounterModel
    let onSave: (CounterModel) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            TextField("Title", text: $counter.title)
                .textFieldStyle(.roundedBorder)
                .padding()

            Text("\(counter.count)")
                .font(.system(size: 80, weight: .bold))
                .frame(minWidth: 150, minHeight: 100)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                        .shadow(radius: 10)
                )
                .foregroundColor(.white)

            HStack(spacing: 40) {
                Button { counter.count -= 1; counter.totalTaps += 1; Haptics.tap() } label: {
                    Image(systemName: "minus.circle.fill").resizable().frame(width: 60, height: 60)
                }
                Button { counter.count = 0; Haptics.tap() } label: {
                    Text("Reset")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                Button { counter.count += 1; counter.totalTaps += 1; Haptics.tap() } label: {
                    Image(systemName: "plus.circle.fill").resizable().frame(width: 60, height: 60)
                }
            }

            Toggle("Religious", isOn: $counter.religious)
                .padding(.horizontal)

            VStack(spacing: 5) {
                Text("Taps: \(counter.totalTaps)").font(.caption).foregroundColor(.secondary)
                Text("Created: \(counter.createdDate, formatter: formatter)").font(.caption2).foregroundColor(.secondary)
            }

            Spacer()
            Button("Done") {
                onSave(counter)
                dismiss()
            }.bold().padding()
        }
    }

    var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }
}
