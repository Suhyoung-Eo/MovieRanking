//
//  CommentListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct CommentListModel {
    
    let commentList: [CommentModel]
    
    init (_ FBComments: [FBCommentModel]) {
        self.commentList = FBComments.compactMap({ FBComments in
            return CommentModel.init(FBComments)
        })
    }
}

extension CommentListModel {
    
    var count: Int {
        return commentList.count
    }
    
    func commentModel(_ index: Int) -> CommentModel {
        return commentList[index]
    }
}

struct CommentModel {
    
    let FBComment: FBCommentModel
    
    init (_ FBComment: FBCommentModel) {
        self.FBComment = FBComment
    }
    
    var userId: String {
        return FBComment.userId
    }
    
    var movieName: String {
        return FBComment.movieName
    }
    
    var grade: Float {
        return FBComment.grade
    }
    
    var comment: String {
        return FBComment.comment
    }
    
    var date: String {
        return FBComment.date
    }
}
