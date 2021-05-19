//
//  Weather.swift
//  CombineWeatherApp
//
//  Created by yeonBlue on 2021/05/19.
//

import Foundation

struct Weather: Codable {
    let data: [WeatherData]
    let count: Int
}

struct WeatherData: Codable {
    let temp: Double?
    let city_name: String?
}

// 구조
//{
//"data":[
//    {
//    "rh":63,
//    "pod":"d",
//    "lon":126.70515,
//    "pres":1009.9,
//    "timezone":"Asia/Seoul",
//    "ob_time":"2021-05-18 23:00",
//    "country_code":"KR",
//    "clouds":0,
//    "ts":1621378800,
//    "solar_rad":457.8,
//    "state_code":"12",
//    "city_name":"Incheon",
//    "wind_spd":1.5,
//    "wind_cdir_full":"south-southwest",
//    "wind_cdir":"SSW",
//    "slp":1012,
//    "vis":5,
//    "h_angle":-51.4,
//    "sunset":"10:38",
//    "dni":758.2,
//    "dewpt":10.9,
//    "snow":0,
//    "uv":5.21699,
//    "precip":0,
//    "wind_dir":210,
//    "sunrise":"20:19",
//    "ghi":457.84,
//    "dhi":91.08,
//    "aqi":189,
//    "lat":37.45646,
//    "weather":{
//        "icon":"c01d",
//        "code":800,
//        "description":"Clear sky"
//    },
//    "datetime":"2021-05-18:23",
//    "temp":18,
//    "station":"RKSS",
//    "elev_angle":29.47,
//    "app_temp":18
//}
//],
//"count":1
//}
