//
//  FBAccountModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct FBGradeModel {
    let DOCID: String
    let movieId: String
    let movieSeq: String
    let movieName: String
    let thumbNailLink: String
    let grade: Float
}

extension FBGradeModel {
    
    static var empty: FBGradeModel {
        return FBGradeModel(DOCID: "",
                            movieId: "",
                            movieSeq: "",
                            movieName: "",
                            thumbNailLink: "",
                            grade: 0.0)
    }
}
