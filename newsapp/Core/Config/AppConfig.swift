import Foundation

enum AppConfig {
    private static let infoPlistKey = "NEWS_API_KEY"
    private static let placeholderValues: Set<String> = [
        "",
        "YOUR_KEY_HERE",
        "$(NEWS_API_KEY)"
    ]

    static var newsAPIKey: String? {
        let raw = Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmed, !trimmed.isEmpty, !placeholderValues.contains(trimmed) else { return nil }
        return trimmed
    }
}

