//
//  ViewController.swift
//  CombineWeatherApp
//
//  Created by yeonBlue on 2021/05/19.
//

import UIKit
import Combine

class ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    
    // MARK: - Properties
    private var weatherService = WeatherService()
    private var cancelables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPublisher()
        
        /*
        self.weatherService.fetchWeather(city: "Seoul")
            .print()
            .catch { _ in Just(WeatherData.placeholder) }
            .map { weather in
                if let temp = weather[0].temp {
                    return "\(temp)°C"
                } else {
                    return "Error"
                }
            }
            .assign(to: \.text, on: self.weatherLabel)
            .store(in: &cancelables)
         */
    }

    private func setUpPublisher() {
        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification,
                                                             object: self.cityTextField)
        publisher
            .compactMap {
                ($0.object as! UITextField).text?
                    .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            }.debounce(for: .milliseconds(500), scheduler: RunLoop.main) // 매 입력 시마다 요청은 비효율적
             .flatMap { city in
                return self.weatherService.fetchWeather(city: city)
                    .catch { _ in Empty() }
                    .map { $0 }
            }.sink {
                self.weatherLabel.text
                    = "\(String(describing: $0[0].city_name!)) : \(String(describing: $0[0].temp!))°C"
            }.store(in: &cancelables)
    }
}

