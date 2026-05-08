import Foundation
import XCTest
@testable import NewsCore

final class DecodingAndCacheTests: XCTestCase {
    func testDecodesTopHeadlinesPayload() throws {
        let json = """
        {
          "status": "ok",
          "totalResults": 1,
          "articles": [
            {
              "source": { "id": "bbc-news", "name": "BBC News" },
              "author": "Some Author",
              "title": "A headline",
              "description": "A description",
              "url": "https://example.com/article",
              "urlToImage": "https://example.com/image.jpg",
              "publishedAt": "2026-05-08T12:34:56Z",
              "content": "More content"
            }
          ]
        }
        """

        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(NewsAPIResponse.self, from: data)

        XCTAssertEqual(payload.status, "ok")
        XCTAssertEqual(payload.totalResults, 1)
        XCTAssertEqual(payload.articles?.count, 1)
        XCTAssertEqual(payload.articles?.first?.source.name, "BBC News")
        XCTAssertEqual(payload.articles?.first?.url.absoluteString, "https://example.com/article")
        XCTAssertEqual(payload.articles?.first?.urlToImage?.absoluteString, "https://example.com/image.jpg")
        XCTAssertNotNil(payload.articles?.first?.publishedAt)
    }

    func testUserDefaultsCacheRoundTripAndTTL() throws {
        let suite = "NewsCoreTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)

        let cache = UserDefaultsNewsCache(userDefaults: defaults, ttl: 60)

        let article = NewsArticle(
            source: NewsSource(id: nil, name: "Unit Test Source"),
            author: nil,
            title: "Title",
            description: "Desc",
            url: URL(string: "https://example.com/a")!,
            urlToImage: nil,
            publishedAt: Date(timeIntervalSince1970: 0),
            content: nil
        )

        let now = Date(timeIntervalSince1970: 1_000)
        cache.save(country: "us", query: "swift", articles: [article], now: now)

        let entry = try XCTUnwrap(cache.load(country: "us", query: "swift"))
        XCTAssertEqual(entry.articles, [article])
        XCTAssertTrue(cache.isFresh(entry, now: now.addingTimeInterval(30)))
        XCTAssertFalse(cache.isFresh(entry, now: now.addingTimeInterval(61)))
    }
}

