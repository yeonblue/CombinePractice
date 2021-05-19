//
//  WeatherService.swift
//  CombineWeatherApp
//
//  Created by yeonBlue on 2021/05/19.
//

import Foundation
import Combine

class WeatherService {
    
    func fetchWeather(city: String) -> AnyPublisher<[WeatherData], Error> {
        guard let url = URL(string: Constants.URLs.weatherURL(city: city)) else { fatalError("Invalid URL")}
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Weather.self, decoder: JSONDecoder())
            .map { $0.data }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
