//
//  CommentListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Foundation

struct CommentListModel {
    let commentList: [CommentModel]
    
    init (_ commentList: [CommentModel]) {
        self.commentList = commentList
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
    let displayName: String
    let grade: Float
    let comment: String
    let date: String
}

extension CommentModel {
    
    static var empty: CommentModel {
        return CommentModel(displayName: "",
                            grade: 0.0,
                            comment: "",
                            date: "")
    }
}
