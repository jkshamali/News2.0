
import SwiftUI
import WebKit

// News Model
struct News: Identifiable, Decodable {
    var id: String { url }
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
}

// News List Decodable to match the API response structure
struct NewsList: Decodable {
    let articles: [News]
}

// News Service for fetching news
class NewsService {
    func getNews(completion: @escaping ([News]?) -> ()) {
        // Your API key is included in the URL
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=ce55790118874ceaad43e3a0fc91280d") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            let newsList = try? JSONDecoder().decode(NewsList.self, from: data)
            DispatchQueue.main.async {
                completion(newsList?.articles)
            }
        }.resume()
    }
}

// SwiftUI View for displaying news details
struct NewsDetailView: View {
    let news: News

    var body: some View {
        WebView(url: URL(string: news.url)!)
            .navigationTitle(news.title)
    }
}

// SwiftUI View for displaying a list of news
struct ContentView: View {
    @State private var newsList: [News] = []
    
    var body: some View {
        NavigationView {
            List(newsList) { news in
                NavigationLink(destination: NewsDetailView(news: news)) {
                    VStack(alignment: .leading) {
                        Text(news.title).font(.headline)
                        Text(news.description ?? "").font(.subheadline)
                    }
                }
            }
            .navigationTitle("News")
            .onAppear {
                NewsService().getNews { news in
                    self.newsList = news ?? []
                }
            }
        }
    }
}

// SwiftUI WebView for displaying web content
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}



