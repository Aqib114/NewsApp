import Foundation
import Combine

@MainActor
final class HeadlinesViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case failed(String)
    }

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var articles: [NewsArticle] = []
    @Published var query: String = ""

    private let service: NewsFetching
    private var currentTask: Task<Void, Never>?

    init(service: NewsFetching) {
        self.service = service
    }

    func load(country: String = "us") {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self else { return }
            await self.loadAsync(country: country, query: self.query)
        }
    }

    func updateQuery(_ newValue: String, debounceNanoseconds: UInt64 = 350_000_000, country: String = "us") {
        query = newValue
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: debounceNanoseconds)
            await self.loadAsync(country: country, query: newValue)
        }
    }

    func refresh(country: String = "us") async {
        currentTask?.cancel()
        await loadAsync(country: country, query: query)
    }

    private func normalizedQuery(_ q: String) -> String? {
        let trimmed = q.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func loadAsync(country: String, query: String) async {
        state = .loading
        do {
            let result = try await service.topHeadlines(country: country, query: normalizedQuery(query))
            articles = result
            state = result.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            // Ignore
        } catch {
            articles = []
            state = .failed((error as? LocalizedError)?.errorDescription ?? "Something went wrong.")
        }
    }
}

