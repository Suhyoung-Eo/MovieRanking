//
//  FBCommentModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct FBCommentModel {
    let userId: String
    let grade: Float
    let comment: String
    let date: String
}

extension FBCommentModel {
    
    static var empty: FBCommentModel {
        return FBCommentModel(userId: "",
                              grade: 0.0,
                              comment: "",
                              date: "")
    }
}
