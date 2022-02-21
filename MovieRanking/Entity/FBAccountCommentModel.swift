//
//  FBUserCommentModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/18.
//

import Foundation

struct FBAccountCommentModel {
    let DOCID: String
    let movieId: String
    let movieSeq: String
    let movieName: String
    let thumbNailLink: String
    let grade: Float
    let comment: String
    let date: String
}

extension FBAccountCommentModel {
    
    static var empty: FBAccountCommentModel {
        return FBAccountCommentModel(DOCID: "",
                                     movieId: "",
                                     movieSeq: "",
                                     movieName: "",
                                     thumbNailLink: "",
                                     grade: 0.0,
                                     comment: "",
                                     date: "")
    }
}
