//
//  MusicianView.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/17.
//

import SwiftUI


/**
 var artistName: String // 이름
 var releaseDate: String // 발매일
 var artistUrl: String // 홈페이지 url
 var artworkUrl100: String // 사진 url
 */
struct MusicianView: View {
    let musician: Musician
    
    var body: some View {
        VStack(alignment: .leading) {
            // SwiftUI에서 웹에서 이미지를 로드하고 표시하려면 AsyncImage를 사용할 수 있습니다. AsyncImage를 사용하면 비동기적으로 이미지를 로드하고 로딩 중에는 placeholder 이미지를 표시할 수 있습니다.
            NavigationLink {
                WebView(urlString: musician.artistUrl)
            } label: {
                AsyncImage(url: URL(string: musician.artworkUrl100)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100) // 이미지 크기 조정
                                } else if phase.error != nil {
                                    Text("Failed to load image")
                                } else {
                                    ProgressView() // 이미지 로딩 중에 표시될 로딩 인디케이터
                                }
                }
                .frame(maxWidth: .infinity)

            }
            Divider()
            Text("**artistName**: \(musician.artistName)")
            Text("**releaseDate**: \(musician.releaseDate)")
            
        }
        .frame(maxWidth: .infinity,
               alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 4)
    }
}

struct MusicianView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MusicianView(musician: .init(id: "", artistName: "Rod Wave", releaseDate: "2023-09-15", artistUrl: "https://music.apple.com/us/artist/rod-wave/1140623439", artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/5b/a7/ea/5ba7eac4-dbbd-8ebf-7ec4-92ee97a442c3/196871436434.jpg/100x100bb.jpg"))
        }
    }
}
