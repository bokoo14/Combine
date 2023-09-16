////
////  URLSessionTest.swift
////  CombineTest
////
////  Created by Bokyung on 2023/09/16.
////
//
//import SwiftUI
//import Combine
//
///**
// url: https://rss.applemarketingtools.com/api/v2/us/music/most-played/50/albums.json
// */
//
//struct AlbumData: Decodable {
//    let artistName: String
//    let contentAdvisoryRating: String
//    let artworkUrl100: URL
//}
//
//struct URLSessionTest: View {
//    @State private var albumData: [AlbumData] = []
//    private var cancellables: Set<AnyCancellable> = []
//
//    var body: some View {
//        List(albumData, id: \.artistName) { data in
//            HStack {
//                URLImage(url: data.artworkUrl100)
//                    .frame(width: 50, height: 50)
//                    .cornerRadius(8)
//
//                VStack(alignment: .leading) {
//                    Text(data.artistName)
//                        .font(.headline)
//                    Text("Content Rating: \(data.contentAdvisoryRating)")
//                        .font(.subheadline)
//                }
//            }
//        }
//        .onAppear {
//            fetchData()
//        }
//    }
//
//    func fetchData() {
//        guard let url = URL(string: "https://rss.applemarketingtools.com/api/v2/us/music/most-played/50/albums.json") else {
//            return
//        }
//
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map(\.data)
//            .decode(type: [String: [AlbumData]].self, decoder: JSONDecoder())
//            .map { $0["results"] ?? [] }
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .finished:
//                        break
//                    case .failure(let error):
//                        print("Error: \(error)")
//                    }
//                },
//                receiveValue: { albumData in
//                    // 여기서 @State로 선언된 albumData를 업데이트합니다.
//                    self.albumData = albumData
//                }
//            )
//            .store(in: &cancellables)
//    }
//
//}
//
//// 이미지를 URL에서 가져와 표시하기 위한 View
//struct URLImage: View {
//    let url: URL
//    @State private var image: UIImage? = nil
//
//    var body: some View {
//        if let image = image {
//            Image(uiImage: image)
//                .resizable()
//        } else {
//            Image(systemName: "photo")
//                .onAppear {
//                    loadImage()
//                }
//        }
//    }
//
//    private func loadImage() {
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map(\.data)
//            .compactMap { UIImage(data: $0) }
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { _ in },
//                receiveValue: { image in
//                    self.image = image
//                }
//            )
//            .store(in: &cancellables)
//    }
//}
//
//struct URLSessionTest_Previews: PreviewProvider {
//    static var previews: some View {
//        URLSessionTest()
//    }
//}
