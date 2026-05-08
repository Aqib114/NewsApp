import Foundation

final class CachedNewsService: NewsFetching {
    private let upstream: NewsFetching
    private let cache: UserDefaultsNewsCache
    private let returnStaleOnError: Bool

    init(
        upstream: NewsFetching,
        cache: UserDefaultsNewsCache = UserDefaultsNewsCache(),
        returnStaleOnError: Bool = true
    ) {
        self.upstream = upstream
        self.cache = cache
        self.returnStaleOnError = returnStaleOnError
    }

    func topHeadlines(country: String, query: String?) async throws -> [NewsArticle] {
        if let entry = cache.load(country: country, query: query), cache.isFresh(entry) {
            return entry.articles
        }

        do {
            let fresh = try await upstream.topHeadlines(country: country, query: query)
            cache.save(country: country, query: query, articles: fresh)
            return fresh
        } catch {
            if let entry = cache.load(country: country, query: query), returnStaleOnError {
                return entry.articles
            }
            throw error
        }
    }
}

