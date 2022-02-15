//
//  FBAccountModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct FBEstimateModel {
    let DOCID: String
    let movieId: String
    let movieSeq: String
    let movieName: String
    let thumbNailLink: String
    let grade: Float
    let comment: String
    let date: String
}

extension FBEstimateModel {
    
    static var empty: FBEstimateModel {
        return FBEstimateModel(DOCID: "",
                               movieId: "",
                               movieSeq: "",
                               movieName: "",
                               thumbNailLink: "",
                               grade: 0.0,
                               comment: "",
                               date: "")
    }
}
