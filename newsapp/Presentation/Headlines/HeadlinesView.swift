import SwiftUI

struct HeadlinesView: View {
    var body: some View {
        NavigationStack {
            Group {
                if AppConfig.newsAPIKey == nil {
                    MissingAPIKeyView()
                } else {
                    HeadlinesListView(service: CachedNewsService(upstream: NewsAPIClient()))
                }
            }
            .navigationTitle("Top Headlines")
        }
    }
}

private struct MissingAPIKeyView: View {
    var body: some View {
        ContentUnavailableView(
            "Missing NewsAPI Key",
            systemImage: "key.fill",
            description: Text("In the newsapp target Build Settings, set the user-defined key NEWS_API_KEY to your NewsAPI key, then clean build.")
        )
    }
}

#Preview {
    HeadlinesView()
}

