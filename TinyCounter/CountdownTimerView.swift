import SwiftUI

struct CountdownTimerView: View {
    let targetDate: Date
    let now: Date

    private let digitHeight: CGFloat = 70
    private let digitWidth: CGFloat = 60

    var body: some View {
        let comps = timeComponents(to: targetDate)

        VStack(spacing: 6) {
            // Digits with colons
            HStack(spacing: 4) {
                flipBlock(text: "\(comps.days)")
                colon
                flipBlock(text: String(format: "%02d", comps.hours))
                colon
                flipBlock(text: String(format: "%02d", comps.minutes))
                colon
                flipBlock(text: String(format: "%02d", comps.seconds))
            }

            // Labels perfectly aligned under each digit
            HStack(spacing: 4) {
                labelBlock("Days")
                Spacer(minLength: 4)
                labelBlock("Hrs")
                Spacer(minLength: 4)
                labelBlock("Min")
                Spacer(minLength: 4)
                labelBlock("Sec")
            }
            .padding(.horizontal, 8)
        }
        .padding(8)
        .background(Color.black)
        .cornerRadius(10)
    }

    // MARK: - Pieces

    private func flipBlock(text: String) -> some View {
        FlipDigitView(value: text)
            .frame(width: digitWidth, height: digitHeight)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }

    private var colon: some View {
        Text(":")
            .font(.system(size: 28, weight: .bold, design: .monospaced)) // 🔥 smaller colon
            .foregroundColor(.white)
            .frame(width: 20)
            .padding(.bottom, 8) // slight adjustment to vertically center it
    }

    private func labelBlock(_ text: String) -> some View {
        VStack {
            Text(text)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: digitWidth)
    }

    private func timeComponents(to target: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, Int(target.timeIntervalSince(now)))
        return (
            days: interval / 86400,
            hours: (interval / 3600) % 24,
            minutes: (interval / 60) % 60,
            seconds: interval % 60
        )
    }
}

struct CountdownTimerView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownTimerView(
            targetDate: Calendar.current.date(byAdding: .day, value: 9999, to: Date())!,
            now: Date()
        )
        .padding()
        .background(Color.gray.opacity(0.2))
        .previewLayout(.sizeThatFits)
    }
}
