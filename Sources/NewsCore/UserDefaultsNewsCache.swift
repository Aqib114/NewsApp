import Foundation

public struct UserDefaultsNewsCache {
    public struct Entry: Codable, Equatable {
        public let cachedAt: Date
        public let articles: [NewsArticle]

        public init(cachedAt: Date, articles: [NewsArticle]) {
            self.cachedAt = cachedAt
            self.articles = articles
        }
    }

    public let userDefaults: UserDefaults
    public let ttl: TimeInterval

    public init(userDefaults: UserDefaults = .standard, ttl: TimeInterval = 10 * 60) {
        self.userDefaults = userDefaults
        self.ttl = ttl
    }

    public func load(country: String, query: String?) -> Entry? {
        guard let data = userDefaults.data(forKey: cacheKey(country: country, query: query)) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Entry.self, from: data)
    }

    public func save(country: String, query: String?, articles: [NewsArticle], now: Date = Date()) {
        let entry = Entry(cachedAt: now, articles: articles)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(entry) else { return }
        userDefaults.set(data, forKey: cacheKey(country: country, query: query))
    }

    public func isFresh(_ entry: Entry, now: Date = Date()) -> Bool {
        now.timeIntervalSince(entry.cachedAt) <= ttl
    }

    private func cacheKey(country: String, query: String?) -> String {
        let normalizedQuery = (query ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return "news.cache.topHeadlines.\(country.lowercased()).q=\(normalizedQuery)"
    }
}

