import SwiftUI

struct ArticleDetailView: View {
    let article: NewsArticle

    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let url = article.urlToImage {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.title2.weight(.semibold))
                        .textSelection(.enabled)

                    Text(article.source.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(article.description?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "No description available.")
                    .font(.body)
                    .textSelection(.enabled)

                Button {
                    openURL(article.url)
                } label: {
                    Text("Read More")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .padding()
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

