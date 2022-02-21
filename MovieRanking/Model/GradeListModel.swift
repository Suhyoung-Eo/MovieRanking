//
//  CurrentUserCommentListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct GradeListModel {
    let gradeList: [GradeModel]
    
    init (_ gradeList: [FBGradeModel]) {
        self.gradeList = gradeList.compactMap({ gradeList in
            return GradeModel.init(gradeList)
        })
    }
}

extension GradeListModel {
    
    var count: Int {
        return gradeList.count
    }
    
    func gradeModel(_ index: Int) -> GradeModel {
        return gradeList[index]
    }
}

struct GradeModel {
    
    let gradeModel: FBGradeModel
    
    init (_ gradeModel: FBGradeModel) {
        self.gradeModel = gradeModel
    }
    
    var DOCID: String {
        return gradeModel.DOCID
    }
    
    var movieId: String {
        return gradeModel.movieId
    }
    
    var movieSeq: String {
        return gradeModel.movieSeq
    }
    
    var movieName: String {
        return gradeModel.movieName
    }
    
    var thumbNailLink: String {
        return gradeModel.thumbNailLink
    }
    
    var grade: Float {
        return gradeModel.grade
    }
}
