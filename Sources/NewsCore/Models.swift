import Foundation

public struct NewsAPIResponse: Codable {
    public let status: String
    public let totalResults: Int?
    public let articles: [NewsArticle]?
    public let code: String?
    public let message: String?

    public init(status: String, totalResults: Int?, articles: [NewsArticle]?, code: String?, message: String?) {
        self.status = status
        self.totalResults = totalResults
        self.articles = articles
        self.code = code
        self.message = message
    }
}

public struct NewsArticle: Codable, Identifiable, Hashable {
    public var id: String { url.absoluteString }

    public let source: NewsSource
    public let author: String?
    public let title: String
    public let description: String?
    public let url: URL
    public let urlToImage: URL?
    public let publishedAt: Date?
    public let content: String?

    public init(
        source: NewsSource,
        author: String?,
        title: String,
        description: String?,
        url: URL,
        urlToImage: URL?,
        publishedAt: Date?,
        content: String?
    ) {
        self.source = source
        self.author = author
        self.title = title
        self.description = description
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
    }
}

public struct NewsSource: Codable, Hashable {
    public let id: String?
    public let name: String

    public init(id: String?, name: String) {
        self.id = id
        self.name = name
    }
}

