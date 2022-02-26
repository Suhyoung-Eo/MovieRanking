//
//  WishToWatchListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct WishToWatchListModel {
    let wishToWatchList: [WishToWatchModel]
    
    init (_ wishToWatchList: [FBWishToWatchModel]) {
        self.wishToWatchList = wishToWatchList.compactMap({ wishToWatchList in
            return WishToWatchModel.init(wishToWatchList)
        })
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
    let wishToWatchModel: FBWishToWatchModel
    
    init (_ wishToWatchModel: FBWishToWatchModel) {
        self.wishToWatchModel = wishToWatchModel
    }
    
    var movieId: String {
        return wishToWatchModel.movieId
    }
    
    var movieSeq: String {
        return wishToWatchModel.movieSeq
    }
    
    var movieName: String {
        return wishToWatchModel.movieName
    }
    
    var thumbNailLink: String {
        return wishToWatchModel.thumbNailLink
    }
    
    var wishToWatch: Bool {
        return wishToWatchModel.isWishToWatch
    }
}
