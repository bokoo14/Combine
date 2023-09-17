//
//  UsersViewModel.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/17.
//

import Foundation
import Combine

final class UsersViewModel: ObservableObject {
    
    @Published var hasError = false
    @Published var error: UserError?
    
    @Published var users: [User] = []
    @Published private(set) var isRefreshing = false
    
    private var bag = Set<AnyCancellable>()
    // Set<AnyCancellable>(): 객체의 집합(set)을 초기화하는 코드입니다. Combine 프레임워크에서 비동기 작업을 관리하고 구독을 추적하는 데 사용
    // AnyCancellable: Combine 프레임워크에서 비동기 작업을 추적하고 관리하기 위한 특별한 타입입니다. AnyCancellable은 Combine에서 Publisher에 대한 구독(subscription)을 나타내며, 이 구독을 통해 비동기 작업을 추적하고 취소할 수 있습니다. Combine에서 메모리 누수를 방지하고 비동기 작업을 효율적으로 관리하는 데 도움이 됩니다.
    
    func fetchUsers() {
        
        hasError = false
        isRefreshing = true
        
        let usersUrlString = "https://jsonplaceholder.typicode.com/users"
        if let url = URL(string: usersUrlString) {
            
            URLSession
                .shared
                .dataTask(with: url) { [weak self] data, response, error in
                    
                    DispatchQueue.main.async {
                        
                        defer {
                            self?.isRefreshing = false
                        }
                        
                        if let error = error {
                            self?.hasError = true
                            self?.error = UserError.custom(error: error)
                        } else {
                            
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase // Handle properties that look like first_name > firstName
                            
                            if let data = data,
                               let users = try? decoder.decode([User].self, from: data) {
                                self?.users = users
                            } else {
                                self?.hasError = true
                                self?.error = UserError.failedToDecode
                            }
                        }
                    }
                }.resume()
            
        }
    }
    
    func fetchUsersNew() {
        
        let usersUrlString = "https://jsonplaceholder.typicode.com/users"
        if let url = URL(string: usersUrlString) {
            
            isRefreshing = true
            hasError = false
            
            //  URLSession.shared: 앱 내에서 네트워크 작업을 수행하는 데 필요한 기본 설정을 가진 공유 인스턴스에 액세스할 수 있습니다.
            // dataTaskPublisher(for:) 메서드를 호출하여 네트워크 요청을 시작합니다. 이 메서드는 주어진 URL을 사용하여 데이터를 가져오는 네트워크 요청을 생성하고, 해당 요청에 대한 Combine Publisher를 반환합니다.
            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main) //Combine 스트림이 메인 스레드에서 처리되도록 하기 위해 receive(on:) 연산자를 사용합니다. 이로써 UI 업데이트 및 다른 UI 관련 작업을 안전하게 수행할 수 있습니다.
                .tryMap({ res in
                    
                    guard let response = res.response as? HTTPURLResponse,
                          response.statusCode >= 200 && response.statusCode <= 299 else {
                        throw UserError.invalidStatusCode
                    }
                    
                    let decoder = JSONDecoder()
                    guard let users = try? decoder.decode([User].self, from: res.data) else {
                        throw UserError.failedToDecode
                    }
                    
                    return users
                })
                .sink { [weak self] res in // publisher가 끝날때 or cancel되었을때를 알아차려서 newValue를 받음
                    
                    defer { self?.isRefreshing = false } // 코드 실행이 완료된 후에 isRefreshing을 false로 설정하도록 합니다.
                    
                    switch res {
                    case .failure(let error):
                        self?.hasError = true
                        self?.error = UserError.custom(error: error)
                    default: break
                    }
                } receiveValue: { [weak self] users in
                    self?.users = users
                } // sink: Combine 스트림의 값을 처리하고, 스트림이 완료되거나 취소될 때의 동작을 정의합니다. 이 연산자는 sink를 통해 Publisher의 값을 구독하고 처리합니다.
                .store(in: &bag)
            //  이 연산자는 sink의 결과를 bag에 저장합니다. bag는 Combine의 x을 저장하고 관리하는 데 사용되는 컨테이너입니다. 이렇게 하면 Combine Publisher 구독을 유지하고 필요하지 않은 경우에 취소할 수 있습니다.
        }
    }
}

extension UsersViewModel {
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
