import AppIntents
import Foundation

struct SelectCountdownIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Choose Countdown"
    static var description = IntentDescription("Select which countdown to display.")

    @Parameter(title: "Countdown")
    var countdown: CountdownEntity?
}


struct CountdownEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "Countdown")
    
    static var defaultQuery = CountdownQuery()

    var id: UUID
    var title: String
    var targetDate: Date
    var imageData: Data?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: title),
            subtitle: LocalizedStringResource(stringLiteral: formattedDate)
        )
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: targetDate)
    }
}


struct CountdownQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [CountdownEntity] {
        let all = CountdownEntity.loadCountdowns()
        return all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [CountdownEntity] {
        CountdownEntity.loadCountdowns()
    }
}

extension CountdownEntity {
    static func loadCountdowns() -> [CountdownEntity] {
        print("🔍 Widget: Attempting to load saved countdowns...")

        guard let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter"),
              let data = defaults.data(forKey: "savedCountdowns") else {
            print("❌ Widget: No savedCountdowns data found.")
            return []
        }


        do {
            let decoded = try JSONDecoder().decode([CountdownItem].self, from: data)
            print("✅ Widget: Loaded \(decoded.count) countdowns.")
            return decoded.map {
                CountdownEntity(
                    id: $0.id,
                    title: $0.title,
                    targetDate: $0.targetDate,
                    imageData: $0.imageData
                )
            }
        } catch {
            print("❌ Widget: Failed to decode countdowns: \(error)")
            return []
        }
    }

}
