//
//  WishToWatchListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct WishToWatchListModel {
    let wishToWatchList: [WishToWatchModel]
    
    init (_ wishToWatchList: [WishToWatchModel]) {
        self.wishToWatchList = wishToWatchList
    }
}

extension WishToWatchListModel {
    
    var count: Int {
        return wishToWatchList.count
    }
    
    func wishToWatchModel(_ index: Int) -> WishToWatchModel {
        return wishToWatchList[index]
    }
}

struct WishToWatchModel {
    let movieId: String
    let movieSeq: String
    let movieName: String
    let thumbNailLink: String
    let isWishToWatch: Bool
    
    enum CodingKeys: String, CodingKey {
        case isWishToWatch = "wishToWatch"
    }
}

extension WishToWatchModel {
    
    static var empty: WishToWatchModel {
        return WishToWatchModel(movieId: "",
                                movieSeq: "",
                                movieName: "",
                                thumbNailLink: "",
                                isWishToWatch: false)
    }
}
