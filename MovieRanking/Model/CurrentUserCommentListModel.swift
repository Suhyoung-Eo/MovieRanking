//
//  CurrentUserCommentListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct CurrentUserCommentListModel {
    let currentUserCommentList: [CurrentUserCommentModel]
    
    init (_ FBUserComments: [FBCurrentUserCommentModel]) {
        self.currentUserCommentList = FBUserComments.compactMap({ FBUserComments in
            return CurrentUserCommentModel.init(FBUserComments)
        })
    }
}

extension CurrentUserCommentListModel {
    
    var count: Int {
        return currentUserCommentList.count
    }
    
    func currentUserCommentModel(_ index: Int) -> CurrentUserCommentModel {
        return currentUserCommentList[index]
    }
}

struct CurrentUserCommentModel {
    
    let FBCurrentComment: FBCurrentUserCommentModel
    
    init (_ FBCurrentComment: FBCurrentUserCommentModel) {
        self.FBCurrentComment = FBCurrentComment
    }
    
    var movieId: String {
        return FBCurrentComment.movieId
    }
    
    var movieSeq: String {
        return FBCurrentComment.movieSeq
    }
    
    var movieName: String {
        return FBCurrentComment.movieName
    }
    
    var thumbNailLink: String {
        return FBCurrentComment.thumbNailLink
    }
    
    var grade: Float {
        return FBCurrentComment.grade
    }
    
    var comment: String {
        return FBCurrentComment.comment
    }
    
    var date: String {
        return FBCurrentComment.date
    }
}
