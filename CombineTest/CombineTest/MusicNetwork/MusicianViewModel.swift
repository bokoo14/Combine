//
//  MusicianViewModel.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/17.
//


import Foundation
import Combine

final class MusicianViewModel: ObservableObject {
    
    @Published var hasError = false
    @Published var error: UserError?
    
    @Published var musician: [Musician] = []
    @Published private(set) var isRefreshing = false // private(set): 속성의 상태를 클래스나 구조체 내부에서만 변경할 수 있도록 제한
    
    
    // Set<AnyCancellable>(): 객체의 집합(set)을 초기화하는 코드입니다. Combine 프레임워크에서 비동기 작업을 관리하고 구독을 추적하는 데 사용
    // AnyCancellable: Combine 프레임워크에서 비동기 작업을 추적하고 관리하기 위한 특별한 타입입니다. AnyCancellable은 Combine에서 Publisher에 대한 구독(subscription)을 나타내며, 이 구독을 통해 비동기 작업을 추적하고 취소할 수 있습니다. Combine에서 메모리 누수를 방지하고 비동기 작업을 효율적으로 관리하는 데 도움이 됩니다.
    private var bag = Set<AnyCancellable>()
  
    /**
     Combine 프레임워크를 사용하여 네트워크 요청과 데이터 처리를 효율적으로 구성합니다.
     데이터를 비동기적으로 가져오기 위해 URLSession.shared.dataTaskPublisher를 사용하며, Combine 프레임워크를 활용합니다.
     데이터를 가져온 후 receive(on:) 연산자를 사용하여 메인 스레드에서 UI 업데이트를 처리합니다.
     tryMap 연산자를 사용하여 네트워크 응답을 검증하고 디코딩합니다.
     sink 연산자를 사용하여 데이터를 처리하고, 오류 처리 및 성공적인 경우 UI 상태를 변경합니다. 또한 Combine의 Cancellable을 활용하여 Publisher 구독을 관리합니다.
     
     fetchUsersNew() 함수가 Combine을 사용하기 때문에 비동기적 작업 및 오류 처리를 더 간결하게 관리할 수 있으며, 코드의 가독성과 유지 보수성을 향상시킬 수 있습니다.
     */
    func fetchUsersNew() {
        let usersUrlString = "https://rss.applemarketingtools.com/api/v2/us/music/most-played/10/albums.json"
        
        if let url = URL(string: usersUrlString) {
            isRefreshing = true
            hasError = false
            
            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap { res in
                    guard let response = res.response as? HTTPURLResponse,
                          response.statusCode >= 200 && response.statusCode <= 299 else {
                        throw UserError.invalidStatusCode
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase // JSON의 snake_case를 camelCase로 자동 변환
                    
                    let result = try decoder.decode(MusicianResponse.self, from: res.data)
                    return result.feed.results
                }
                .sink { [weak self] res in
                    defer { self?.isRefreshing = false }
                    
                    switch res {
                    case .failure(let error):
                        self?.hasError = true
                        self?.error = UserError.custom(error: error)
                    default: break
                    }
                } receiveValue: { [weak self] musicians in
                    self?.musician = musicians
                }
                .store(in: &bag)
        }
    }
}


extension MusicianViewModel {
    enum UserError: LocalizedError {
        case custom(error: Error)
        case failedToDecode
        case invalidStatusCode
        
        var errorDescription: String? {
            switch self {
            case .failedToDecode:
                return "Failed to decode response"
            case .custom(let error):
                return error.localizedDescription
            case .invalidStatusCode:
                return "Request doesn't fall in the valid status code"
            }
        }
    }
}
