

import SwiftUI

@main
struct NWSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(.blue)
        }
        
    }
}

struct ContentView: View {
    @State private var newsList: [News] = []
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            NavigationView {
                List(newsList) { news in
                    NavigationLink(destination: NewsDetailView(news: news)) {
                        HStack {
                            if let imageUrl = news.urlToImage,
                               let imageData = loadImage(url: imageUrl) {
                                Image(uiImage: UIImage(data: imageData)!)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                            }
                            VStack(alignment: .leading) {
                                Text(news.title)
                                    .font(.headline)
                                    .lineLimit(2)
                                Text(news.description ?? "")
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    
                }
                .background(.blue)
                .navigationTitle("NEWS")
                .onAppear {
                    NewsService().getNews { news in
                        self.newsList = news ?? []
                    }
                }
            }
            .background(.blue)
        }

    }
    
    private func loadImage(url: String) -> Data? {
        guard let imageUrl = URL(string: url),
              let imageData = try? Data(contentsOf: imageUrl) else {
            return nil
        }
        return imageData
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
