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
    @Published private(set) var isRefreshing = false // private(set): 속성의 상태를 클래스나 구조체 내부에서만 변경할 수 있도록 제한
    
    private var bag = Set<AnyCancellable>()
    // Set<AnyCancellable>(): 객체의 집합(set)을 초기화하는 코드입니다. Combine 프레임워크에서 비동기 작업을 관리하고 구독을 추적하는 데 사용
    // AnyCancellable: Combine 프레임워크에서 비동기 작업을 추적하고 관리하기 위한 특별한 타입입니다. AnyCancellable은 Combine에서 Publisher에 대한 구독(subscription)을 나타내며, 이 구독을 통해 비동기 작업을 추적하고 취소할 수 있습니다. Combine에서 메모리 누수를 방지하고 비동기 작업을 효율적으로 관리하는 데 도움이 됩니다.
    
    
    /**
     클래식한 네트워크 요청 및 비동기 코드 스타일을 사용합니다.
     데이터를 비동기적으로 가져오기 위해 URLSession.shared.dataTask를 사용하며, 클로저 내에서 네트워크 요청을 처리합니다.
     데이터를 가져온 후 메인 스레드에서 UI 업데이트를 수행하려면 DispatchQueue.main.async 블록 내에서 UI 관련 코드를 처리합니다.
     @Published 속성을 직접 업데이트하고, 오류 처리 및 데이터 디코딩을 수행한 후 UI 상태를 변경합니다.
     */
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
    
    
    /**
     Combine 프레임워크를 사용하여 네트워크 요청과 데이터 처리를 효율적으로 구성합니다.
     데이터를 비동기적으로 가져오기 위해 URLSession.shared.dataTaskPublisher를 사용하며, Combine 프레임워크를 활용합니다.
     데이터를 가져온 후 receive(on:) 연산자를 사용하여 메인 스레드에서 UI 업데이트를 처리합니다.
     tryMap 연산자를 사용하여 네트워크 응답을 검증하고 디코딩합니다.
     sink 연산자를 사용하여 데이터를 처리하고, 오류 처리 및 성공적인 경우 UI 상태를 변경합니다. 또한 Combine의 Cancellable을 활용하여 Publisher 구독을 관리합니다.
     
     fetchUsersNew() 함수가 Combine을 사용하기 때문에 비동기적 작업 및 오류 처리를 더 간결하게 관리할 수 있으며, 코드의 가독성과 유지 보수성을 향상시킬 수 있습니다.
     */
    func fetchUsersNew() {
        
        let usersUrlString = "https://jsonplaceholder.typicode.com/users"
        if let url = URL(string: usersUrlString) {
            
            isRefreshing = true
            hasError = false
            
            //  URLSession.shared: 앱 내에서 네트워크 작업을 수행하는 데 필요한 기본 설정을 가진 공유 인스턴스에 액세스할 수 있습니다.
            // dataTaskPublisher(for:) 메서드를 호출하여 네트워크 요청을 시작합니다. 이 메서드는 주어진 URL을 사용하여 데이터를 가져오는 네트워크 요청을 생성하고, 해당 요청에 대한 Combine Publisher를 반환합니다.
            URLSession.shared.dataTaskPublisher(for: url)
            // receive(on:): Combine 스트림이 메인 스레드에서 처리되도록 하기 위해 사용. UI 업데이트 및 다른 UI 관련 작업을 안전하게 수행할 수 있습니다.
                .receive(on: DispatchQueue.main)
            
            // tryMap: 네트워크 응답을 검증하고 디코딩합니다.
                .tryMap({ res in
                    
                    guard let response = res.response as? HTTPURLResponse,
                          response.statusCode >= 200 && response.statusCode <= 299 else {
                        throw UserError.invalidStatusCode
                    }
                    
                    print(response)
                    let decoder = JSONDecoder()
                    guard let users = try? decoder.decode([User].self, from: res.data) else {
                        throw UserError.failedToDecode
                    }
                    print(users)
                    return users
                })
            
            // sink: 데이터를 처리하고, 오류 처리 및 성공적인 경우 UI 상태를 변경합니다. Combine의 Cancellable을 활용하여 Publisher 구독을 관리합니다. Combine 스트림의 값을 처리하고, 스트림이 완료되거나 취소될 때의 동작을 정의합니다. 이 연산자는 sink를 통해 Publisher의 값을 구독하고 처리합니다.
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
                }
            
            // store: sink의 결과를 bag에 저장합니다. bag는 Combine의 x을 저장하고 관리하는 데 사용되는 컨테이너입니다. 이렇게 하면 Combine Publisher 구독을 유지하고 필요하지 않은 경우에 취소할 수 있습니다. bag는 Combine의 구독을 관리하고 취소할 때 사용되는 컨테이너입니다.
                .store(in: &bag)
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
