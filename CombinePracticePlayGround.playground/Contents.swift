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

// 1. prepend, append
let arr1 = (1...3).publisher
let arr2 = (201...203).publisher

arr1.prepend(50, 60)
    .prepend([33, 44])
    .prepend(arr2) // publisher도 pretend 가능
    .append(-1) // append는 맨 뒤에 추가
    .sink {
    print($0)
}

// 결과
// 201
// 202
// 203
// 33
// 44
// 50
// 60
// 1
// 2
// 3
// -1

// 2. swicthToLastest

let sub1 = PassthroughSubject<String, Never>()
let sub2 = PassthroughSubject<String, Never>()

let publishers = PassthroughSubject<PassthroughSubject<String, Never>, Never>()

publishers
    .switchToLatest()
    .sink {
        print($0)
    }

publishers.send(sub1)
sub1.send("sub1: 1")
sub2.send("sub2: 1")

publishers.send(sub2) // sub2로 switch
sub1.send("sub1: 2")
sub2.send("sub2: 2")

// 결과
// sub1: 1
// sub2: 2

// 활용 예시
let imageNames = ["monkey", "tiger", "lion"]
var index = 0

func getImage() -> AnyPublisher<UIImage?, Never> {
    // Future Publisher: A publisher that eventually produces a single value and then finishes or fails.
    return Future<UIImage?, Never> { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) {
            promise(.success(UIImage(named: imageNames[index])))
        }
    }
    .print()
    .map { $0 }
    .receive(on: RunLoop.main)
    .eraseToAnyPublisher()
}
let tap = PassthroughSubject<Void, Never>()
let subscription = tap.map { _ in
        getImage()
    }
    .switchToLatest()
    .sink {
        print($0)
    }

// monkey
tap.send()

// tiger
// DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//    index += 1
//    tap.send()
//}

// lion
// DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//    index += 1
//    tap.send()
//}


// 3. merge

let pub1 = PassthroughSubject<Int, Never>()
let pub2 = PassthroughSubject<Int, Never>()

pub1
    .merge(with: pub2)
    .sink {
        print($0)
    }

pub1.send(100)
pub2.send(101)

// 4. combineLatest
// pub1            a     b         c
// pub2  1    2               3
// combine         2a    2b   3b   3c

let publish1 = PassthroughSubject<Int, Never>()
let publish2 = PassthroughSubject<String,Never>()

publish1.combineLatest(publish2)
    .sink { intVal, strVal in
        print("intVal: ", intVal, "strVal: ", strVal)
    }

publish1.send(1)
publish1.send(2)
publish2.send("a")
publish2.send("b")
publish1.send(3)
publish2.send("c")


// 4. zip
// pub1            a     b         c    d
// pub2  1    2               3
// combine         1a   2b        3c

let zipPublish1 = PassthroughSubject<Int, Never>()
let zipPublish2 = PassthroughSubject<String,Never>()

zipPublish1.zip(zipPublish2)
    .sink { intVal, strVal in
        print("intVal: ", intVal, "strVal: ", strVal)
    }

zipPublish1.send(1)
zipPublish1.send(2)
zipPublish2.send("a")
zipPublish2.send("b")
zipPublish1.send(3)
zipPublish2.send("c")
zipPublish2.send("d")

// MARK: - Sequence Operators

// 1. min and max
let minMaxPublisher = [1, -3, 22, 999].publisher

minMaxPublisher
    .min() // .max()
    .sink {
        print($0)
    }


// 2. first and last
let firstPublisher = ["A", "B", "C", "D"].publisher
firstPublisher
    .first()
    .sink {
        print($0)
    }

firstPublisher
    .first(where: {
        "Cat".contains($0)
    })
    .sink {
        print($0)
    }

firstPublisher
    .last()
    .sink {
        print($0) // D
    }

// 3. output
let outputPublish = ["A", "B", "C", "D"].publisher

outputPublish.output(at: 2)
    .sink {
        print($0) // C가 반환
    }

outputPublish.output(in: (0...2))
    .sink {
        print($0) // A, B, C
    }

// 4. count
let countPulbisher = ["A", "B", "C", "D"].publisher
let countPassPulbisher = PassthroughSubject<Int, Never>()

countPulbisher.count()
    .sink {
        print($0) // 4가 리턴(총 4개)
    }

countPassPulbisher.count()
    .sink {
        print($0)  // 5, 15, 25, finished를 보냈으므로 3이 리턴
    }

countPassPulbisher.send(5)
countPassPulbisher.send(15)
countPassPulbisher.send(25)
countPassPulbisher.send(completion: .finished)

// 5. contains

let containPublisher = ["A", "B", "C", "D"].publisher
containPublisher.contains("C")
    .sink {
        print($0) // C가 있으므로 true가 반환
    }

// 6. allSatisfy
let allSatisfyPublisher = [1, 2, 3, 4, 5, 6].publisher
allSatisfyPublisher
    .allSatisfy {
        $0 % 2 == 0 // 모든 요소가 해당 조건을 만족해야 함. 홀수가 있으므로 false
    }
    .sink {
        print($0)
    }

// 7. reduce

let reducePublisher = [1, 2, 3, 4, 5, 6].publisher

reducePublisher
    .reduce(0) { accumulator, value in
        print("accumulator: ", accumulator, " value: ", value)
        return accumulator + value
    }
    .sink {
        print($0)
    }

// 결과
// accumulator:  0  value:  1
// accumulator:  1  value:  2
// accumulator:  3  value:  3
// accumulator:  6  value:  4
// accumulator:  10  value:  5
// accumulator:  15  value:  6
// 21


// MARK: - Network

struct PostData: Codable {
    let title: String
    let body: String
}

let jsonURL = URL(string: "jsonplaceholder.typicode.com/posts")
func getPost() -> AnyPublisher<[PostData], Error> {
    guard let jsonURL = URL(string: "http://jsonplaceholder.typicode.com/posts") else { fatalError("Invalid URL")}
    
    return URLSession.shared.dataTaskPublisher(for: jsonURL)
        .map { $0.data }
        .decode(type: [PostData].self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}

let cancelable = getPost().sink { _ in
    print("completed")
} receiveValue: { data in
    //print(data)
}

// MARK: - Debugging Combine

// 1. print
let printPublisher = (1...10).publisher
printPublisher
    .print("DEBUG")
    .sink {
        print($0)
    }
    
// 결과
// DEBUG: receive subscription: (1...10)
// DEBUG: request unlimited
// DEBUG: receive value: (1)
// 1
// DEBUG: receive value: (2)
// 2
// DEBUG: receive value: (3)
// 3
// DEBUG: receive value: (4)
// 4
// DEBUG: receive value: (5)
// 5
// DEBUG: receive value: (6)
// 6
// DEBUG: receive value: (7)
// 7
// DEBUG: receive value: (8)
// 8
// DEBUG: receive value: (9)
// 9
// DEBUG: receive value: (10)
// 10
// DEBUG: receive finished

// 2. handleEvents
guard let jsonURL2 = URL(string: "http://jsonplaceholder.typicode.com/posts") else { fatalError("InvalidURL") }

let request = URLSession.shared.dataTaskPublisher(for: jsonURL2)
request // 이렇게 하면 hold하는 것이 없어서 error
    .handleEvents(receiveSubscription: { subscription in
        print("Subscription Received: ", subscription)
    }, receiveOutput: { data, response in
        print("Data:", data, "Response:", response)
    }, receiveCompletion: { comp in
        print("comp:", comp)
    }, receiveCancel: {
        print("Received Cancel")
    }, receiveRequest: { request in
        print("Received Request:", request)
    })
    .sink(receiveCompletion: { print($0) }) { data, response in
        print(data)
    }

let handleEventSubscription = request 
    .handleEvents(receiveSubscription: { subscription in
        print("Subscription Received: ", subscription)
    }, receiveOutput: { data, response in
        print("Data:", data, "Response:", response)
    }, receiveCompletion: { comp in
        print("comp:", comp)
    }, receiveCancel: {
        print("Received Cancel")
    }, receiveRequest: { request in
        print("Received Request:", request)
    })
    .sink(receiveCompletion: { print($0) }) { data, response in
        print(data)
    }

// MARK: - Timer
// 일정 간격으로 event 발생 등 사용

// 1. RunLoop
    
let runLoop = RunLoop.main
let timerPublisher1 = runLoop.schedule(after: runLoop.now,
                                       interval: .seconds(2),
                                       tolerance: .milliseconds(100),
                                       options: .none) {
    print("Timer Fired")
}

runLoop.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) {
    timerPublisher1.cancel() // cancel하지 않으면 위의 스케쥴러가 2초마다 계속 반복
}

// 2. Timer Class

let timerPublisher2 =
    Timer.publish(every: 1.0, on: .main, in: .common) // tracking: user의 반응에 따라 동작 가능
    .autoconnect()
    .scan(0) { counter, value in
        counter + 1
    }
    .sink { value in
        print("Timer Fired!", value)
        
        // 결과
        // Timer Fired! 3
        // Timer Fired! 4
        // Timer Fired! 5.... 1초마다 1씩 counter 증가 하여 반영
    }

// 3. DispatchQueue

let queue = DispatchQueue.main
let queueSubject = PassthroughSubject<Int, Never>()

var count = 0

let cancellable = queue.schedule(after: queue.now,           // 별도 변수에 저장 필수
                                 interval: .seconds(1)) {
    queueSubject.send(count)
    count += 1
}

let queueSubscription = queueSubject.sink { value in
    print("Value:", value)
}


// MARK: - Resources Combine

// 1. share

guard let jsonURL3 = URL(string: "http://jsonplaceholder.typicode.com/posts") else { fatalError("InvalidURL") }

var shareSub3: AnyCancellable? = nil

let shareRequest = URLSession.shared.dataTaskPublisher(for: jsonURL3)
    .share() // share를 이용하면 동일한 publisher를 구독하는 다른 subscriber가 있어도 공용하여 각각 stream이 발생하지 않음.
             // 첫번째 subscriber만 다운받고 두번째부터는 share

let shareSub1 = request.sink { _ in
    print("shareSub1 completion")
} receiveValue: {
    print("shareSub2")
    print($0)
}

let shareSub2 = request.sink { _ in
    print("shareSub2 completion")
} receiveValue: {
    print("shareSub2")
    print($0)
}


// 3초 후에 할당되므로 이미 request는 이미 다운로드 완료
// 따라서 shareSub3는 값을 얻지 못함
DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
    shareSub3 = request.sink { _ in
        print("shareSub3 completion")
    } receiveValue: {
        print("shareSub3")
        print($0)
    }
}


// 2. multicast

let multiSubject = PassthroughSubject<Data, URLError>()
let multiRequest = URLSession.shared.dataTaskPublisher(for: jsonURL3)
    .map { $0.data }
    .multicast(subject: multiSubject)

multiRequest.connect() // 시간이 지난 이후 subscription해도 연결을 해줌
multiSubject.send(Data())
