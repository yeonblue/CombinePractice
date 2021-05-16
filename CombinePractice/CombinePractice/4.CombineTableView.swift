//
//  TableViewController.swift
//  CombinePractice
//
//  Created by yeonBlue on 2021/05/16.
//

import UIKit
import Combine

class Webservice {
    
    func getPosts() -> AnyPublisher<[Post],Error> {
    
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
          fatalError("Invalid URL")
      }
      
      return URLSession.shared.dataTaskPublisher(for: url).map { $0.data }
      .decode(type: [Post].self, decoder: JSONDecoder())
      .receive(on: RunLoop.main) // UI Update는 반드시 main thread
      .eraseToAnyPublisher()
    }
}

struct Post: Codable {
    let title: String
    let body: String
}


class TableViewController: UITableViewController {
    
    private var webservice = Webservice()
    private var cancellable: AnyCancellable?
    // 뷰컨트롤러가 있는 동안 subscription은 유지, 이게 없으면 한번 값이 불르고 나면 메모리에서 지워짐
    
    private var posts = [Post]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cancellable = self.webservice.getPosts()
            .catch { _ in Just(self.posts)} // decode fail등 에러 발생 시 전달할 데이터, 이미 empty로 초기화 되어있음.
            .assign(to: \.posts, on: self) // 값이 오면 특정 property에 할당
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let post = self.posts[indexPath.row]
        cell.textLabel?.text = post.title
        
        return cell
    }
    
}
