//
//  PassthroughSubjectTest.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/15.
//

import SwiftUI
import Combine

/**
 PassthroughSubject는 초기값을 가지지 않습니다.
 직전에 방출한 값을 저장하지 않습니다.
 값을 방출할 때마다 구독자(subscriber)들에게 방출합니다.
 주로 이벤트 및 미래에 발생할 이벤트를 구독자에게 알리는 데 사용됩니다.
 예시: 사용자 인터페이스에서 버튼 클릭 또는 사용자 입력과 같은 이벤트를 구독하고, 해당 이벤트가 발생할 때마다 구독자에게 알릴 때 사용됩니다.

 */
struct PassthroughSubjectTest: View {
    var body: some View {
        // Combine 작업은 SwiftUI View의 body 내에서 발생해야 합니다.
        let subject = PassthroughSubject<String, Never>()

        return Text("Hello, World!")
            .onAppear {
                subject.sink { value in
                    print("Received value: \(value)")
                }

                subject.send("Hello, World!")
            }
    }
}



struct PassthroughSubjectTest_Previews: PreviewProvider {
    static var previews: some View {
        PassthroughSubjectTest()
    }
}
