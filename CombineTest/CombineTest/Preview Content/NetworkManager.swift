//
//  NetworkManager.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/17.
//

import SwiftUI
import Combine

/**
 api를 통해 데이터를 요청하고, 테이블 뷰를 새로고침하기
 */
class NetworkManager {
    // single 톤 패턴
    static let shared = NetworkManager()
    
    // subscriber들의 메모리를 참조 할 수 있는 저장소
    //private var cancellables = Set() // cancellables는 publisher을 구독하는 subscriber들의 메모리를 참조 할 수 있는 저장소이다. 나중에 나오겠지만 store 메서드를 통해 저장하는 로직이 나온다.
    private let baseURL = "<https://jsonplaceholder.typicode.com/>"
    
    // 실패 할 수 있는 Future publisher을 반환합니다.
    func getData<T: Decodable>(endPoint: Endpoint, type: T.Type) -> Future<[T], Error> {
        
        return Future<[T], Error> { [weak self] promise in
            // Future의 경우 Apple에서 제공해주는 Publisher
            // promise : (Result<[T], Error>) -> Void
            // 여기서 promise는 Future의 결과를 하나의 클로저로 받는 argument임
            // 이 내부에서, 비동기작업을 수행 할 수 있습니다.
            // 비동기 작업이 끝났을 때, 작업의 결과(failure or success)를 promise에 넣어줘야합니다.
            
            // URL 검증
            guard let self = self, let url = URL(string: self.baseURL.appending(endPoint.rawValue)) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            print("URL is \\(url.absoluteString)")
            
        }
    }
    
}




// baseURL 뒤에 붙게 될 주소 값
enum Endpoint: String {
    case posts
}

// network 에러 처리 종류
enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

// network 에러 처리 description
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}

