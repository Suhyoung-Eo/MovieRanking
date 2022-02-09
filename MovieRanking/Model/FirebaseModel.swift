//
//  FirebaseModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

struct MovieModel {
    let gradeAverage: Float
}

struct CommentModel {
    let userId: String
    let movieName: String
    let grade: Float
    let comment: String
    let date: String
}

struct AccountModel {
    let DOCID: String
    let movieId: String
    let movieSeq: String
    let wishToWatch: Bool
}
