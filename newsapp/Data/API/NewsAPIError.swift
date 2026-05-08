import Foundation

enum NewsAPIError: Error, LocalizedError, Equatable {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed
    case apiError(code: String?, message: String?)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing NewsAPI key."
        case .invalidURL:
            return "Could not build request URL."
        case .invalidResponse:
            return "Unexpected server response."
        case .httpStatus(let status):
            return "Request failed (HTTP \(status))."
        case .decodingFailed:
            return "Could not decode server response."
        case .apiError(_, let message):
            return message ?? "NewsAPI returned an error."
        }
    }
}

