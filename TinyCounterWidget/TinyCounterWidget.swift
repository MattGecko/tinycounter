import WidgetKit
import SwiftUI
import AppIntents

struct CountdownEntry: TimelineEntry {
    let date: Date
    let countdown: CountdownEntity?
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        .init(date: Date(), countdown: nil)
    }
    func snapshot(for configuration: SelectCountdownIntent, in context: Context) async -> CountdownEntry {
        .init(date: Date(), countdown: configuration.countdown)
    }
    func timeline(for configuration: SelectCountdownIntent, in context: Context) async -> Timeline<CountdownEntry> {
        let now = Date()
        let next = Calendar.current.date(byAdding: .minute, value: 1, to: now)!
        let entry = CountdownEntry(date: now, countdown: configuration.countdown)
        return Timeline(entries: [entry], policy: .after(next))
    }
}

struct TinyCounterWidgetEntryView: View {
    var entry: CountdownEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:  smallView
        case .systemMedium: mediumView
        case .systemLarge:  largeView
        @unknown default:   mediumView
        }
    }

    // MARK: Small
    private var smallView: some View {
        ZStack(alignment: .center) {
            // Use background directly, consistent with medium/large
           // background
            //    .clipped() // Clip to widget bounds
            
            // Text overlay
            if let cd = entry.countdown {
                Text(shortTime(to: cd.targetDate))
                    .font(.subheadline.monospacedDigit()) // Larger font for readability
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.7) // Allow less shrinking
                    .lineLimit(1)
                    .padding(3) // Slightly reduced padding
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(4)
                    .padding(3)
            } else {
                Text("No Countdown")
                    .font(.caption) // Slightly larger than .caption2
                    .foregroundColor(.secondary)
                    .padding(3)
            }
        }
        .containerBackground(for: .widget) {
            background}
    }
        

    // MARK: Medium (unchanged)
    private var mediumView: some View {
        ZStack {
         //   background
            if let cd = entry.countdown {
                VStack(spacing: 8) {
                    Text(cd.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 2)

                    Text(fullTime(to: cd.targetDate))
                        .font(.title2.monospacedDigit())
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .padding()
            } else {
                Text("No Countdown Selected")
                    .foregroundColor(.secondary)
            }
        }
        .containerBackground(for: .widget) {
            background}
    }

    // MARK: Large (unchanged)
    private var largeView: some View {
        ZStack {
        //    background
            VStack(spacing: 12) {
                if let cd = entry.countdown {
                    Text(cd.title)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .multilineTextAlignment(.center)

                    Text(fullTime(to: cd.targetDate))
                        .font(.title.monospacedDigit())
                        .foregroundColor(.white)
                        .shadow(radius: 2)

                    HStack {
                        timeColumn(value: days(to: cd.targetDate), unit: "Days")
                        timeColumn(value: hours(to: cd.targetDate) % 24, unit: "Hrs")
                        timeColumn(value: minutes(to: cd.targetDate) % 60, unit: "Min")
                    }
                } else {
                    Text("No Countdown Selected")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(12)
            .padding()
        }
        .containerBackground(for: .widget) {
            background}
    }

    // MARK: Shared
    private var background: some View {
        Group {
            if let cd = entry.countdown,
               let data = cd.imageData,
               let ui = UIImage(data: data) {
                // Resize image for small widget to reduce memory usage
                let resizedImage = resizeImage(ui, targetSize: CGSize(width: 310, height: 310))
                Image(uiImage: resizedImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea() // Use .scaledToFit for small widget
            } else {
                Color.blue.opacity(0.2)
                    .ignoresSafeArea() // Fallback background
            }
        }
    }

    // Helper function to resize UIImage
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newRatio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * newRatio, height: size.height * newRatio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private func shortTime(to target: Date) -> String {
        let i = max(0, Int(target.timeIntervalSince(Date())))
        let d = i / 86400, h = (i / 3600) % 24
        return String(format: "%dd %02dh", d, h)
    }
    private func fullTime(to target: Date) -> String {
        let i = max(0, Int(target.timeIntervalSince(Date())))
        let d = i / 86400, h = (i / 3600) % 24, m = (i / 60) % 60, s = i % 60
        return String(format: "%02dd %02dh %02dm %02ds", d, h, m, s)
    }
    private func days(to target: Date) -> Int { max(0, Int(target.timeIntervalSince(Date()))) / 86400 }
    private func hours(to target: Date) -> Int { (max(0, Int(target.timeIntervalSince(Date()))) / 3600) % 24 }
    private func minutes(to target: Date) -> Int { (max(0, Int(target.timeIntervalSince(Date()))) / 60) % 60 }
    private func timeColumn(value: Int, unit: String) -> some View {
        VStack {
            Text("\(value)")
                .font(.title.monospacedDigit().bold())
                .foregroundColor(.white)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

struct TinyCounterWidget: Widget {
    let kind: String = "TinyCounterWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCountdownIntent.self,
            provider: Provider()
        ) { entry in
            TinyCounterWidgetEntryView(entry: entry)
     //           .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct TinyCounterWidgetBundle: WidgetBundle {
    var body: some Widget {
        TinyCounterWidget()
    }
}
