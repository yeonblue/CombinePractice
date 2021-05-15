//
//  ViewController.swift
//  CombinePractice
//
//  Created by yeonBlue on 2021/05/14.
//

import UIKit
import Combine

private class StringSubscriber: Subscriber {
    
    // publish, subscription 절차
    // 1. Publisher <-- Subscriber    subscribes(back pressure)
    // 2. Publisher --> Subscriber    gives subscription
    // 3. Publisher <-- Subscriber    requests values
    // 4. Publisher --> Subscriber    sends values
    // 5. Publisher <-- Subscriber    sends completion
    
    typealias Input = String
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        print("Received Subscription")
        subscription.request(.max(3)) // back pressure, publisher가 많이 보낼 수도 있지만 최대 이것만 보내라고 표시
    }
    
    func receive(_ input: String) -> Subscribers.Demand {
        print("Received Value", input) // Demand: Back Pressure를 주거나, 더 보낼지 말지 결정
        return .none // keep it like that, ABC만 주기로 했으나 더 줄 수도 있음 지금은 기존 ABC 유지
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Completion")
    }
}

class CombinePractice2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let publisher = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N"].publisher
        
        let subscriber = StringSubscriber()
        publisher.subscribe(subscriber)
        
        // Result
        // Received Subscription
        // Received Value A
        // Received Value B
        // Received Value C

        // unlimited로 변경 시
        // Received Subscription
        // Received Value A
        // Received Value B
        // Received Value C
        // Received Value D
        // Received Value E
        // Received Value F
        // Received Value G
        // Received Value H
        // Received Value I
        // Received Value J
        // Received Value K
        // Received Value L
        // Received Value M
        // Received Value N
        // Completion
    }
}
