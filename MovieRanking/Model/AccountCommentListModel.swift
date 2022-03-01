//
//  UserCommentListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/18.
//

import Foundation

struct AccountCommentListModel {
    let accountCommentList: [AccountCommentModel]
    
    init (_ accountCommentList: [AccountCommentModel]) {
        self.accountCommentList = accountCommentList
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
    let DOCID: String
    let movieId: String
    let movieSeq: String
    let movieName: String
    let thumbNailLink: String
    let grade: Float
    let comment: String
    let date: String
}

extension AccountCommentModel {
    
    static var empty: AccountCommentModel {
        return AccountCommentModel(DOCID: "",
                                   movieId: "",
                                   movieSeq: "",
                                   movieName: "",
                                   thumbNailLink: "",
                                   grade: 0.0,
                                   comment: "",
                                   date: "")
    }
}
