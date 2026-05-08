import Foundation

protocol NewsFetching {
    func topHeadlines(country: String, query: String?) async throws -> [NewsArticle]
}

final class NewsAPIClient: NewsFetching {
    private let session: URLSession
    private let apiKeyProvider: () -> String?
    private let baseURL: URL

    init(
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://newsapi.org")!,
        apiKeyProvider: @escaping () -> String? = { AppConfig.newsAPIKey }
    ) {
        self.session = session
        self.baseURL = baseURL
        self.apiKeyProvider = apiKeyProvider
    }

    func topHeadlines(country: String = "us", query: String? = nil) async throws -> [NewsArticle] {
        guard let apiKey = apiKeyProvider(), !apiKey.isEmpty else { throw NewsAPIError.missingAPIKey }

        var components = URLComponents(url: baseURL.appendingPathComponent("/v2/top-headlines"), resolvingAgainstBaseURL: false)
        var items: [URLQueryItem] = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "pageSize", value: "50")
        ]
        if let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            items.append(URLQueryItem(name: "q", value: query))
        }
        components?.queryItems = items

        guard let url = components?.url else { throw NewsAPIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw NewsAPIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw NewsAPIError.httpStatus(http.statusCode) }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let payload = try decoder.decode(NewsAPIResponse.self, from: data)
            if payload.status.lowercased() != "ok" {
                throw NewsAPIError.apiError(code: payload.code, message: payload.message)
            }
            return payload.articles ?? []
        } catch let err as NewsAPIError {
            throw err
        } catch {
            throw NewsAPIError.decodingFailed
        }
    }
}

