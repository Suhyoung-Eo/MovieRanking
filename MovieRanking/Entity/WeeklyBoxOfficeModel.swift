//
//  WeeklyBoxOfficeListModel.swift
//  MovingMovie
//
//  Created by Suhyoung Eo on 2021/12/29.
//

import Foundation

// 영화진흥위원회
struct WeeklyBoxOfficeModel: Codable {
    let boxOfficeResult: WeeklyBoxOfficeResult
}

struct WeeklyBoxOfficeResult: Codable {
    let weeklyBoxOfficeList: [BoxOffice]
}
