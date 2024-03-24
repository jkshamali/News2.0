import SwiftUI
import WebKit

// News Model
struct News: Identifiable, Decodable {
    var id: String { url }
    let title: String
    let description: String?
    let content: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
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
    
    func loadImage(url: String, completion: @escaping (Data?) -> ()) {
        guard let imageUrl = URL(string: url) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            completion(data)
        }.resume()
    }
}

// SwiftUI View for displaying news details
struct NewsDetailView: View {
    let news: News

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let imageUrl = news.urlToImage,
                   let imageData = loadImage(url: imageUrl) {
                    Image(uiImage: UIImage(data: imageData)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(news.title)
                        .font(.title)
                        .padding(.bottom, 8)
                    if let description = news.description {
                        GeometryReader { geometry in
                            Text(description)
                                .font(.body)
                                .padding(.horizontal, geometry.size.width * 0.1)
                        }
                    }
                    if let content = news.content {
                        Text(content)
                            .font(.body)
                            .padding(.horizontal, 10)
                    }
                }
                .padding(.all, 16)
                
                Spacer()
            }
        }
        .navigationTitle(news.title)
    }
    
    private func loadImage(url: String) -> Data? {
        guard let imageUrl = URL(string: url),
              let imageData = try? Data(contentsOf: imageUrl) else {
            return nil
        }
        return imageData
    }
}

// SwiftUI View for displaying a list of news
