//
//  CurrentUserCommentListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct GradeListModel {
    let gradeList: [GradeModel]
    
    init (_ gradeList: [GradeModel]) {
        self.gradeList = gradeList
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
    let DOCID: String
    let movieId: String
    let movieSeq: String
    let movieName: String
    let thumbNailLink: String
    let grade: Float
}

extension GradeModel {
    
    static var empty: GradeModel {
        return GradeModel(DOCID: "",
                          movieId: "",
                          movieSeq: "",
                          movieName: "",
                          thumbNailLink: "",
                          grade: 0.0)
    }
}
