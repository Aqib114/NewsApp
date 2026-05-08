import SwiftUI

struct HeadlinesListView: View {
    @StateObject private var viewModel: HeadlinesViewModel
    @State private var searchText: String = ""

    init(service: NewsFetching) {
        _viewModel = StateObject(wrappedValue: HeadlinesViewModel(service: service))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                List {
                    if viewModel.state == .loading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                    ForEach(viewModel.articles) { article in
                        NavigationLink(value: article) {
                            ArticleRowView(article: article)
                        }
                    }
                }
                .listStyle(.plain)

            case .loaded:
                List(viewModel.articles) { article in
                    NavigationLink(value: article) {
                        ArticleRowView(article: article)
                    }
                }
                .listStyle(.plain)

            case .empty:
                ContentUnavailableView(
                    "No results",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different keyword.")
                )

            case .failed(let message):
                ContentUnavailableView(
                    "Couldn’t load headlines",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            }
        }
        .navigationDestination(for: NewsArticle.self) { article in
            ArticleDetailView(article: article)
        }
        #if os(iOS) 
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search headlines")
        #else
        .searchable(text: $searchText, prompt: "Search headlines")
        #endif
        .onChange(of: searchText) { _, newValue in
            viewModel.updateQuery(newValue)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .toolbar {
            if case .failed = viewModel.state {
                Button("Retry") { viewModel.load() }
            }
        }
        .task {
            searchText = viewModel.query
            viewModel.load()
        }
    }
}

