//
//  ViewDrawTest.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/16.
//

import SwiftUI
import Combine

class CounterViewModel: ObservableObject {
    @Published var count: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Combine을 사용하여 count의 변경을 구독하고 처리
        $count
            .sink { newValue in
                print("Count changed to: \(newValue)")
            }
            .store(in: &cancellables)
    }
}

struct ViewDrawTest: View {
    @ObservedObject var viewModel = CounterViewModel()
    
    var body: some View {
        VStack {
            Text("Count: \(viewModel.count)")
            
            Button(action: {
                self.viewModel.count += 1
            }) {
                Text("Increment")
            }
        }
    }
}

struct ViewDrawTest_Previews: PreviewProvider {
    static var previews: some View {
        ViewDrawTest()
    }
}
