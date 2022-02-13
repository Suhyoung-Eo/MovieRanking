//
//  FBAccountModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct FBCurrentUserCommentModel {
    let movieId: String
    let movieSeq: String
    let movieName: String
    let thumbNailLink: String
    let grade: Float
    let comment: String
    let date: String
}

extension FBCurrentUserCommentModel {
    
    static var empty: FBCurrentUserCommentModel {
        return FBCurrentUserCommentModel(movieId: "",
                              movieSeq: "",
                              movieName: "",
                              thumbNailLink: "",
                              grade: 0.0,
                              comment: "",
                              date: "")
    }
}
