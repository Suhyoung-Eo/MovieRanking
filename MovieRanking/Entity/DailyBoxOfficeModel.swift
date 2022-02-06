//
//  BoxOfficeResultModel.swift
//  MovingMovie
//
//  Created by Suhyoung Eo on 2021/11/15.
//

import Foundation

// 영화진흥위원회
struct DailyBoxOfficeModel: Codable {
    let boxOfficeResult: DailyBoxOfficeResult

}

struct DailyBoxOfficeResult: Codable {
    let dailyBoxOfficeList: [BoxOffice]
}

struct BoxOffice: Codable {
    let rank: String
    let rankOldAndNew: String
    let movieCd: String
    let movieNm: String
    let openDt: String
    let audiAcc: String
}

extension BoxOffice {
    static var empty: BoxOffice {
        return BoxOffice(rank: "",
                             rankOldAndNew: "",
                             movieCd: "",
                             movieNm: "",
                             openDt: "",
                             audiAcc: "")
    }
}
