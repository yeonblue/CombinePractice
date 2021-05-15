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


// 4 - CurrentValueSubject, flatmap
struct School {
    let name: String
    let numOfStudents: CurrentValueSubject<Int, Never>
    
    init(name: String, numOfStudents: Int) {
        self.name = name
        self.numOfStudents = CurrentValueSubject(numOfStudents)
    }
}

let sampleSchool = School(name: "Sample School", numOfStudents: 500)

let school = CurrentValueSubject<School,Never>(sampleSchool)

school.sink {
    print($0)
}

let anotherSchool = School(name: "Another School", numOfStudents: 100)
school.value = anotherSchool

// 결과
// School(name: "Sample School", numOfStudents: Combine.CurrentValueSubject<Swift.Int, Swift.Never>)
// School(name: "Another School", numOfStudents: Combine.CurrentValueSubject<Swift.Int, Swift.Never>)

// 하지만 아래는 이벤트가 발생하지 않음
sampleSchool.numOfStudents.value = 300

// 하지만 flatmap을 사용하면 internal Change가 반영됨을 확인 가능
// internal event를 capture 가능

school
    .flatMap {
        $0.numOfStudents
    }
    .sink {
    print("FlatMap:", $0)
}

anotherSchool.numOfStudents.value = 300
anotherSchool.numOfStudents.value = 200

// 5. replace nil
["A", "B", nil, "C"].publisher
    .replaceNil(with: "!")
    .sink {
        print($0)
        
        // 결과
        // Optional("A")
        // Optional("B")
        // Optional("!")
        // Optional("C")

    }


["A", "B", nil, "C"].publisher
    .replaceNil(with: "!")
    .map { $0! }
    .sink {
        print($0)
        
        // 결과
        // A
        // B
        // !
        // C

    }

// 6. Empty
let empty = Empty<Int, Never>()

empty.sink(receiveCompletion: { print($0)}) { data in
    print(data)
}
// 결과
// finished


// 작업이 끝났다고 전달하고 싶거나, 값을 전달하지 않고 끝났음을 알릴 때 적합
empty
    .replaceEmpty(with: 1)
    .sink(receiveCompletion: { print( $0 ) }, receiveValue: { print( $0 )})

// 결과
// 1
// finished


// 7. scan
let publisher7 = (1...10).publisher
publisher7.scan([]){ num, value -> [Int] in
    print("scan :", num, value)
    return num + [ value ]
}.sink {
    print($0)
}


// 결과 (num, value), [] = initial value
// scan : [] 1
// scan : [1] 2
// scan : [1, 2] 3
// scan : [1, 2, 3] 4
// scan : [1, 2, 3, 4] 5
// scan : [1, 2, 3, 4, 5] 6
// scan : [1, 2, 3, 4, 5, 6] 7
// scan : [1, 2, 3, 4, 5, 6, 7] 8
// scan : [1, 2, 3, 4, 5, 6, 7, 8] 9
// scan : [1, 2, 3, 4, 5, 6, 7, 8, 9] 10


// [1]
// [1, 2]
// [1, 2, 3]
// [1, 2, 3, 4]
// [1, 2, 3, 4, 5]
// [1, 2, 3, 4, 5, 6]
// [1, 2, 3, 4, 5, 6, 7]
// [1, 2, 3, 4, 5, 6, 7, 8]
// [1, 2, 3, 4, 5, 6, 7, 8, 9]
// [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


// MARK: - Filtering Operators

// 1, filter

let numbers1 = (1...10).publisher
numbers1.filter { $0 % 2 == 0 }
    .sink {
        print($0) // 2, 4, 6, 8, 10
    }

// 2. removeDuplicates
let words = "apple apple apple banana mango grape apple wetermelon apple apple strawberry"
    .components(separatedBy: " ")
    .publisher

words
    .removeDuplicates()
    .sink {
    print($0)
}

// 결과
// apple   연속으로 중복되는 경우만 제거
// banana
// mango
// grape
// apple
// wetermelon
// apple
// strawberry


// 3. compactMap
let strings = ["a", "b", "3.25", "2.4", "e", "4.2"]
                .publisher
                .compactMap{Float($0)}
                .sink { print($0) }

// 4. ignoreOutput
let numbers4 = (1...100).publisher

numbers4
    .ignoreOutput()
    .sink(receiveCompletion: { value in
    print("completion:", value)
}, receiveValue: { value in
    print("receiveValue:", value)
})

// finish만 출력


// 5. first
let numbers5 = (1...10).publisher
numbers5.first(where: { $0 % 2 == 0})
    .sink {
        print($0)
    }

// 결과: 2 하나만 출력 (조건에 맞는 1개만 반환)

// 6. last
let numbers6 = (1...10).publisher
numbers6.last(where: { $0 % 2 == 0 })
    .sink {
        print($0)
    }

// 결과: 마지막 조건에 맞는 값인 10이 반환

// 7. dropFirst
let numbers7 = (1...10).publisher
numbers7.dropFirst(8)
    .sink {
        print($0)
    }
// 1 ~ 8은 drop되고 9, 10만 출력

// 8. drop while
let numbers8 = (1...10).publisher
numbers8.drop(while: { $0 % 3 != 0})
    .sink { print($0 )}

// 처음 false가 된 이후부터는 조건이 만족되도 drop하지 않음



// 9. drop UntilOutForm
let taps = PassthroughSubject<Int, Never>()
let isReday = PassthroughSubject<Void, Never>()

taps.drop(untilOutputFrom: isReday)
    .sink {
        print($0)
    }

(1...10).forEach { value in
    taps.send(value)
    
    if value == 5 {
        isReday.send()
    }
    
    // 5부터 isReady를 send() 하였으므로
    // 6, 7, 8, 9, 10만 전달
}

// 10. prefix
let numbers10 = (1...10).publisher
numbers10.prefix(7)
    .sink {
        print($0) // 1 ~ 7만 출력
    }

numbers10.prefix(while: { $0 < 3})
    .sink {
        print($0) // 조건이 맞을때까지 출력
    }


// TEST
let test = (1...100).publisher
test.dropFirst(50)
    .prefix(20)
    .filter { $0 % 2 == 0 }
    .sink {
        print($0)
    }

// MARK: - Combining Operators


// MARK: - Sequence Operators
