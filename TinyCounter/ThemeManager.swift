import SwiftUI

struct AppTheme: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let isPremium: Bool
    let primary: ColorData
    let background: ColorData
    let text: ColorData
}

struct ColorData: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
    }

    init(_ color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        red = Double(r)
        green = Double(g)
        blue = Double(b)
    }
}

class ThemeManager: ObservableObject {
    @Published var selectedTheme: AppTheme
    @Published var customThemes: [AppTheme]

    @AppStorage("selectedThemeId") private var selectedThemeId = ""

    private let customKey = "customThemes"

    init() {
        let savedCustomThemes = ThemeManager.loadCustomThemes()
        self.customThemes = savedCustomThemes

        let allThemes = ThemeManager.defaultThemes + savedCustomThemes
        if let savedId = UserDefaults(suiteName: "group.angelapps.tinycounter")?.string(forKey: "selectedThemeId"),
           let matchingTheme = allThemes.first(where: { $0.id.uuidString == savedId }) {
            self.selectedTheme = matchingTheme
        } else {
            self.selectedTheme = ThemeManager.defaultThemes.first!
        }
    }

    var allThemes: [AppTheme] {
        ThemeManager.defaultThemes + customThemes
    }

    func selectTheme(_ theme: AppTheme) {
        selectedTheme = theme
        selectedThemeId = theme.id.uuidString
        if let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter") {
            defaults.set(theme.id.uuidString, forKey: "selectedThemeId")
        }
    }

    func addCustomTheme(_ theme: AppTheme) {
        customThemes.append(theme)
        saveCustomThemes()
    }

    func deleteCustomTheme(_ theme: AppTheme) {
        customThemes.removeAll { $0.id == theme.id }
        saveCustomThemes()
    }

    private func saveCustomThemes() {
        if let data = try? JSONEncoder().encode(customThemes),
           let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter") {
            defaults.set(data, forKey: customKey)
        }
    }

    static func loadCustomThemes() -> [AppTheme] {
        if let defaults = UserDefaults(suiteName: "group.angelapps.tinycounter"),
           let data = defaults.data(forKey: "customThemes"),
           let decoded = try? JSONDecoder().decode([AppTheme].self, from: data) {
            return decoded
        } else {
            return []
        }
    }

    static let defaultThemes: [AppTheme] = [
        AppTheme(id: UUID(), name: "Default", isPremium: false,
                 primary: ColorData(.blue), background: ColorData(.white), text: ColorData(.primary)),
        AppTheme(id: UUID(), name: "Ocean", isPremium: false,
                 primary: ColorData(.cyan), background: ColorData(.blue.opacity(0.1)), text: ColorData(.primary)),
        AppTheme(id: UUID(), name: "Sunset", isPremium: false,
                 primary: ColorData(.orange), background: ColorData(.pink.opacity(0.2)), text: ColorData(.primary)),
        AppTheme(id: UUID(), name: "Lemon", isPremium: false,
                 primary: ColorData(.yellow), background: ColorData(.yellow.opacity(0.1)), text: ColorData(.black)),
        AppTheme(id: UUID(), name: "Forest", isPremium: false,
                 primary: ColorData(.green), background: ColorData(.green.opacity(0.1)), text: ColorData(.primary)),
        AppTheme(id: UUID(), name: "Aurora", isPremium: true,
                 primary: ColorData(.green), background: ColorData(.black), text: ColorData(.white)),
        AppTheme(id: UUID(), name: "Galaxy", isPremium: true,
                 primary: ColorData(.purple), background: ColorData(.black), text: ColorData(.white)),
        AppTheme(id: UUID(), name: "Firefly", isPremium: true,
                 primary: ColorData(.yellow), background: ColorData(.black), text: ColorData(.yellow)),
        AppTheme(id: UUID(), name: "Retro", isPremium: true,
                 primary: ColorData(.mint), background: ColorData(.orange.opacity(0.2)), text: ColorData(.black)),
        AppTheme(id: UUID(), name: "Neon", isPremium: true,
                 primary: ColorData(.pink), background: ColorData(.black), text: ColorData(.pink)),
        AppTheme(id: UUID(), name: "Midnight", isPremium: true,
                 primary: ColorData(.gray), background: ColorData(.black), text: ColorData(.white)),
        AppTheme(id: UUID(), name: "Bubblegum", isPremium: true,
                 primary: ColorData(.pink), background: ColorData(.white), text: ColorData(.pink)),
        AppTheme(id: UUID(), name: "Velvet", isPremium: true,
                 primary: ColorData(.indigo), background: ColorData(.purple.opacity(0.1)), text: ColorData(.white))
    ]
}
