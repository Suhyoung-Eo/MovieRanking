//
//  UserCommentListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/18.
//

import Foundation

struct AccountCommentListModel {
    let accountCommentList: [AccountCommentModel]
    
    init (_ accountCommentList: [FBAccountCommentModel]) {
        self.accountCommentList = accountCommentList.compactMap({ accountCommentList in
            return AccountCommentModel.init(accountCommentList)
        })
    }
}

extension AccountCommentListModel {
    
    var count: Int {
        return accountCommentList.count
    }
    
    func accountCommentModel(_ index: Int) -> AccountCommentModel {
        return accountCommentList[index]
    }
}

struct AccountCommentModel {
    
    let accountCommentModel: FBAccountCommentModel
    
    init (_ userCommentModel: FBAccountCommentModel) {
        self.accountCommentModel = userCommentModel
    }
    
    var DOCID: String {
        return accountCommentModel.DOCID
    }
    
    var movieId: String {
        return accountCommentModel.movieId
    }
    
    var movieSeq: String {
        return accountCommentModel.movieSeq
    }
    
    var movieName: String {
        return accountCommentModel.movieName
    }
    
    var thumbNailLink: String {
        return accountCommentModel.thumbNailLink
    }
    
    var grade: Float {
        return accountCommentModel.grade
    }
    
    var comment: String {
        return accountCommentModel.comment
    }
    
    var date: String {
        return accountCommentModel.date
    }
}
