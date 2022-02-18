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
    
    let commentModel: FBCommentModel
    
    init (_ commentModel: FBCommentModel) {
        self.commentModel = commentModel
    }
    
    var userId: String {
        return commentModel.userId
    }
    
    var movieName: String {
        return commentModel.movieName
    }
    
    var grade: Float {
        return commentModel.grade
    }
    
    var comment: String {
        return commentModel.comment
    }
    
    var date: String {
        return commentModel.date
    }
}
