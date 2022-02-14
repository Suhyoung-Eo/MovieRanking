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
    let gradeAverage: Float
    let isWishToWatch: Bool
    let date: String
}

extension FBWishToWatchModel {
    
    static var empty: FBWishToWatchModel {
        return FBWishToWatchModel(movieId: "",
                                  movieSeq: "",
                                  movieName: "",
                                  thumbNailLink: "",
                                  gradeAverage: 0.0,
                                  isWishToWatch: false,
                                  date: "")
    }
}
