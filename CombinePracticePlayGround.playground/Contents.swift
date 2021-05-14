import UIKit
import Combine

// MARK: - Transforming Operators
// 1 - Collect
["A", "B", "C", "D"].publisher
    .collect(3) // A, B, C, D로 보내질 것을 ["A", "B", "C"], ["D"] 로 전송
    .sink{
        print($0)
    }

// 2 - Map

let formatter = NumberFormatter()
formatter.numberStyle = .spellOut
formatter.locale = Locale(identifier: "ko-kr")

[123, 45, 67].publisher
    .map { formatter.string(from: $0) ?? "" }
    .sink {
        print($0)
    }

// 3 - map keyPath
struct Point {
    let x: Int
    let y: Int
}

let publisher = PassthroughSubject<Point, Never>()
publisher.map(\.x, \.y)
    .sink { x, y in
        print("x is \(x), y is \(y)")
    }

publisher.send(Point(x: 3, y: 3))

