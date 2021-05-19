//
//  Constatns.swift
//  CombineWeatherApp
//
//  Created by yeonBlue on 2021/05/19.
//

import Foundation

struct Constants {
    struct URLs {
        static let testURL = "https://api.weatherbit.io/v2.0/current?city=seoul&key=4369fd2fcad24f21b39355af07074845"
        
        static func weatherURL(city: String) -> String {
            return "https://api.weatherbit.io/v2.0/current?city=\(city)&key=4369fd2fcad24f21b39355af07074845"
        }
    }
}
