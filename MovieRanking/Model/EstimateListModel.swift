//
//  CurrentUserCommentListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct EstimateListModel {
    let estimateList: [EstimateModel]
    
    init (_ FBEstimateModel: [FBEstimateModel]) {
        self.estimateList = FBEstimateModel.compactMap({ FBEstimateModel in
            return EstimateModel.init(FBEstimateModel)
        })
    }
}

extension EstimateListModel {
    
    var count: Int {
        return estimateList.count
    }
    
    func estimateModel(_ index: Int) -> EstimateModel {
        return estimateList[index]
    }
}

struct EstimateModel {
    
    let FBEstimateModel: FBEstimateModel
    
    init (_ FBEstimateModel: FBEstimateModel) {
        self.FBEstimateModel = FBEstimateModel
    }
    
    var movieId: String {
        return FBEstimateModel.movieId
    }
    
    var movieSeq: String {
        return FBEstimateModel.movieSeq
    }
    
    var movieName: String {
        return FBEstimateModel.movieName
    }
    
    var thumbNailLink: String {
        return FBEstimateModel.thumbNailLink
    }
    
    var grade: Float {
        return FBEstimateModel.grade
    }
    
    var comment: String {
        return FBEstimateModel.comment
    }
    
    var date: String {
        return FBEstimateModel.date
    }
}
