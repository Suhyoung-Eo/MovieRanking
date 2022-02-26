//
//  FBWishToWatchModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct FBWishToWatchModel {
    let movieId: String
    let movieSeq: String
    let movieName: String
    let thumbNailLink: String
    let isWishToWatch: Bool
    
    enum CodingKeys: String, CodingKey {
        case movieId
        case movieSeq
        case movieName
        case thumbNailLink
        case isWishToWatch = "wishToWatch"
    }
}

extension FBWishToWatchModel {
    
    static var empty: FBWishToWatchModel {
        return FBWishToWatchModel(movieId: "",
                                  movieSeq: "",
                                  movieName: "",
                                  thumbNailLink: "",
                                  isWishToWatch: false)
    }
}
