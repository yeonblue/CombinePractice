//
//  ViewController.swift
//  CombinePractice
//
//  Created by yeonBlue on 2021/05/14.
//

import UIKit
import Combine

class CombinePractice1: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 기존
        let noti = Notification.Name("MyNoti")
        let observer = NotificationCenter.default.addObserver(forName: noti, object: nil, queue: nil) { noti in
            print("received")
        }
        
        NotificationCenter.default.post(name: noti, object: nil)
        NotificationCenter.default.removeObserver(observer)
        
        
        
        
        // Combine
        let combineNoti = Notification.Name("CombineNoti")
        let publisher = NotificationCenter.default.publisher(for: combineNoti, object: nil)
        
        NotificationCenter.default.post(name: combineNoti, object: nil)
        
        let subscription = publisher.sink { noti in
            print("combineNoti Received")
        } // 구독 이전에 Post한 것은 오지 않음.
        
        NotificationCenter.default.post(name: combineNoti, object: nil)
        
        subscription.cancel() // 구독을 취소하면 더 이상 오지 않음.
        
        // 구독만 취소했기 떄문에 해당 Post는 발송이 됨
        // subscription이 out of scope가 되면 자동 cancel됨
        NotificationCenter.default.post(name: combineNoti, object: nil)
    }
}

