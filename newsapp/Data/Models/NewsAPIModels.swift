import Foundation

struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int?
    let articles: [NewsArticle]?
    let code: String?
    let message: String?
}

struct NewsArticle: Codable, Identifiable, Hashable {
    var id: String { url.absoluteString }

    let source: NewsSource
    let author: String?
    let title: String
    let description: String?
    let url: URL
    let urlToImage: URL?
    let publishedAt: Date?
    let content: String?
}

struct NewsSource: Codable, Hashable {
    let id: String?
    let name: String
}

