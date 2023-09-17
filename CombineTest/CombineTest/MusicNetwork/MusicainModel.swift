//
//  MusicainModel.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/17.
//

import Foundation

// artistName, releaseDate, artistUrl, artworkUrl100

struct Musician: Codable, Identifiable {
    var id: String // JSON에서 "id" 키에 해당하는 값을 디코딩합니다.
    var artistName: String // 이름
    var releaseDate: String // 발매일
    var artistUrl: String // 홈페이지 url
    var artworkUrl100: String // 사진 url

    // 이니셜라이저 추가
    init(id: String, artistName: String, releaseDate: String, artistUrl: String, artworkUrl100: String) {
        self.id = id
        self.artistName = artistName
        self.releaseDate = releaseDate
        self.artistUrl = artistUrl
        self.artworkUrl100 = artworkUrl100
    }
}

struct MusicianResponse: Codable {
    let feed: Feed
}

struct Feed: Codable {
    let results: [Musician]
}


