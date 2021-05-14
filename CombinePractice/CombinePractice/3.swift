//
//  ViewController.swift
//  CombinePractice
//
//  Created by yeonBlue on 2021/05/14.
//

import UIKit
import Combine

enum MyError: Error {
    case subscribeError
}

private class StringSubscriber: Subscriber {
    
    typealias Input = String
    typealias Failure = MyError
    
    func receive(subscription: Subscription) {
        subscription.request(.max(2))
    }
    
    func receive(_ input: String) -> Subscribers.Demand {
        print(input)
        return .max(1) // 매번 max값이 1씩 증가
    }
    
    func receive(completion: Subscribers.Completion<MyError>) {
        print("Completion")
    }
}

class CombinePractice3: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subjects - Publiser이며 Subscribers임
        
        let subscriber = StringSubscriber()
        
        let subject = PassthroughSubject<String, MyError>()
        subject.subscribe(subscriber)
        
        let subscription = subject.sink { (completion) in
            print("Received Completion from sink")
        } receiveValue: { value in
            print("Received Value from sink")
        }

        
        subject.send("A")
        subject.send("B")
        subject.send("C") // subscription.request(.max(2))로 인해 무시됨
       
        subscription.cancel()

        subject.send("D")
        subject.send("E") // return .max(1) 일 경우 전부 출력 매번 max가 1씩 증가됨
        
        // 결과
        // Received Value from sink
        // A
        // Received Value from sink
        // B
        // Received Value from sink
        // C
        // D
        // E
        
        // 참고 Type Eraser
        let publisher = PassthroughSubject<Int, Never>()
            .eraseToAnyPublisher() // passthroughsubject인걸 모르게 함, AnyPublier로 리턴
         
    }
}
