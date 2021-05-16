//
//  ViewController.swift
//  CombinePractice
//
//  Created by yeonBlue on 2021/05/16.
//

import UIKit
import Combine

class ViewController: UIViewController {

    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let publisher = (1...10).publisher
        
        self.cancellable = publisher
            //.breakpointOnError()
            .breakpoint(receiveOutput: { value in
                return value > 9
            })
            .sink {
            print($0)
        }
    }
}
