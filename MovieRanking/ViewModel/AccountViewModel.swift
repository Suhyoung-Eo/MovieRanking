//
//  AccountViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/17.
//

import Foundation

class AccountViewModel {
    
    var gotErrorStatus: () -> Void = {}
    var onUpdatedMovieInfo: () -> Void = {}
    
    private let FBService = FirebaseService()
    private let movieInfoService = MovieInformationService()
    
    var wishToWatchListModel: WishToWatchListModel!
    var gradeListModel: GradeListModel!
    
    var error: Error? {
        didSet {
            gotErrorStatus()
        }
    }
    
    var movieInfoModel: MovieInfoModel! {
        didSet {
            onUpdatedMovieInfo()
        }
    }
    
    var userId: String? {
        return FBService.userId
    }
    
    var isMovieInfoModelEmpty: Bool {
        return movieInfoModel.DOCID.isEmpty
    }
    
    var accountCommentListCount: Int {
        return accountCommentListModel == nil ? 0 : accountCommentListModel.count
    }
    
    func register(email: String, password: String) {
        FBService.register(email: email, password: password) { [weak self] error in self?.error = error }
    }
    
    func logIn(email: String, password: String) {
        FBService.logIn(email: email, password: password) { [weak self] error in self?.error = error }
    }
    
    func logOut() {
        FBService.logOut { [weak self] error in self?.error = error }
    }
    
    //MARK: - For StorageViewController
    
    var gradeListCount: Int {
        return gradeListModel == nil ? 0 : gradeListModel.count
    }
    
    var wishToWatchListCount: Int {
        return wishToWatchListModel == nil ? 0 : wishToWatchListModel.count
    }
    
    func storageNumberOfItems(by title: String) -> Int {
        switch title {
        case K.Prepare.wishToWatchListView:
            return wishToWatchListCount
        case K.Prepare.gradeListView:
            return gradeListCount
        default:
            return 0
        }
    }
    
    func loadWishToWatchList(completion: @escaping (Error?) -> Void) {
        wishToWatchListModel = nil
        FBService.loadWishToWatchList { [weak self] wishToWatchListModel, error in
            guard error == nil else { completion(error); return }
            self?.wishToWatchListModel = wishToWatchListModel
            completion(nil)
        }
    }
    
    func loadGradeList(completion: @escaping (Error?) -> Void) {
        gradeListModel = nil
        FBService.loadGradeList { [weak self] gradeListModel, error in
            guard error == nil else { completion(error); return }
            self?.gradeListModel = gradeListModel
            completion(nil)
        }
    }
    
    //MARK: - For CommentsViewController
    
    var onUpdatedAccountCommentList: () -> Void = {}
    
    var prepareId: String = ""
    var comment: String = ""
    var grade: Float = 0.0
    
    var accountCommentListModel: AccountCommentListModel! {
        didSet {
            onUpdatedAccountCommentList()
        }
    }
    
    func fetchAccountCommentList() {
        accountCommentListModel = nil
        FBService.loadAccountCommentList { [weak self] accountCommentListModel, error in
            if let error = error {
                self?.error = error
            } else {
                self?.accountCommentListModel = accountCommentListModel
            }
        }
    }
        
    func deleteComment(userId: String?, index: Int) {
        let movieInfo = accountCommentListModel.accountCommentModel(index)
        FBService.deleteComment(collection: userId, document: movieInfo.DOCID) { [weak self] error in
            self?.error = error
        }
    }
    
    //MARK: - 공통함수: StorageViewController / CommentsViewController
    
    func fetchMovieInfo(by itemTitle: String, index: Int) {
        var movieId: String = ""
        var movieSeq: String = ""
        
        switch itemTitle {
        case K.Prepare.wishToWatchListView:
            let movieInfo = wishToWatchListModel.wishToWatchModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        case K.Prepare.gradeListView:
            let movieInfo = gradeListModel.gradeModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        case K.Prepare.addCommentView:
            let movieInfo = accountCommentListModel.accountCommentModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
            comment = movieInfo.comment
            grade = movieInfo.grade
            prepareId = K.Prepare.addCommentView
        case K.Prepare.movieInfoView:
            let movieInfo = accountCommentListModel.accountCommentModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
            prepareId = K.Prepare.movieInfoView
        default:
            break
        }

        movieInfoService.fetchMovieInfo(id: movieId, seq: movieSeq) { [weak self] movieInfoList, error in
            if let error = error {
                self?.error = error
            } else {
                self?.movieInfoModel = movieInfoList.movieInfoModel(0)
            }
        }
    }
}
