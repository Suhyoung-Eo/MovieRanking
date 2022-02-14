//
//  BoxOfficeListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import Foundation

class BoxOfficeListModel {
    let boxOfficeList: [BoxOfficeModel]
    
    init(_ boxOffice: [BoxOffice]) {
        self.boxOfficeList = boxOffice.compactMap({ BoxOffice in
            return BoxOfficeModel.init(BoxOffice)
        })
    }
}

extension BoxOfficeListModel {
    
    var count: Int {
        return boxOfficeList.count
    }
    
    func boxOfficeModel(_ index: Int) -> BoxOfficeModel {
        return boxOfficeList[index]
    }
}

struct BoxOfficeModel {
    private let boxOffice: BoxOffice
    
    init(_ boxOfficeList: BoxOffice) {
        self.boxOffice = boxOfficeList
    }
    
    var movieRank: String {
        return boxOffice.rank
    }
    var rankOldAndNew: String {
        return boxOffice.rankOldAndNew
    }
    var movieCd: String {
        return boxOffice.movieCd
    }
    var movieName: String {
        return boxOffice.movieNm
    }
    var openDate: String {
        return boxOffice.openDt
    }
    var audiAcc: String {
        let numberFormtter = NumberFormatter()
        numberFormtter.numberStyle = .decimal
        let audiAccNum = Int(boxOffice.audiAcc)
        let audiAcc = numberFormtter.string(from: NSNumber(value: audiAccNum ?? 0))
        return audiAcc ?? ""
    }
}
