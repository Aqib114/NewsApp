import Foundation

struct UserDefaultsNewsCache {
    struct Entry: Codable {
        let cachedAt: Date
        let articles: [NewsArticle]
    }

    let userDefaults: UserDefaults
    let ttl: TimeInterval

    init(userDefaults: UserDefaults = .standard, ttl: TimeInterval = 10 * 60) {
        self.userDefaults = userDefaults
        self.ttl = ttl
    }

    func load(country: String, query: String?) -> Entry? {
        guard let data = userDefaults.data(forKey: cacheKey(country: country, query: query)) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Entry.self, from: data)
    }

    func save(country: String, query: String?, articles: [NewsArticle]) {
        let entry = Entry(cachedAt: Date(), articles: articles)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(entry) else { return }
        userDefaults.set(data, forKey: cacheKey(country: country, query: query))
    }

    func isFresh(_ entry: Entry) -> Bool {
        Date().timeIntervalSince(entry.cachedAt) <= ttl
    }

    private func cacheKey(country: String, query: String?) -> String {
        let normalizedQuery = (query ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return "news.cache.topHeadlines.\(country.lowercased()).q=\(normalizedQuery)"
    }
}

