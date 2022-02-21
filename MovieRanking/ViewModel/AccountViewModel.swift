//
//  AccountViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/17.
//

import Foundation

class AccountViewModel {
    
    private let FBService = FirebaseService()
    private let movieInfoService = MovieInformationService()
    
    var movieInfoModel: MovieInfoModel!
    var wishToWatchListModel: WishToWatchListModel!
    var gradeListModel: GradeListModel!
    var accountCommentListModel: AccountCommentListModel!
    
    var userId: String? {
        return FBService.userId
    }
    
    var accountCommentListCount: Int {
        return accountCommentListModel == nil ? 0 : accountCommentListModel.count
    }
    
    func register(email: String, password: String, completion: @escaping (Error?) -> Void) {
        FBService.register(email: email, password: password) { error in completion(error) }
    }
    
    func logIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        FBService.logIn(email: email, password: password) { error in completion(error) }
    }
    
    func logOut(completion: @escaping (Error?) -> Void) {
        FBService.logOut { error in
            guard error == nil else { completion(error); return }
            completion(nil)
        }
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
    
    func loadMovieInfo(by itemTitle: String, index: Int, completion: @escaping (Error?) -> Void) {
        movieInfoModel = nil
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
        case K.Prepare.userCommentView:
            let movieInfo = accountCommentListModel.accountCommentModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        default:
            break
        }

        movieInfoService.fetchMovieInfo(id: movieId, seq: movieSeq) { [weak self] movieInfoList, error in
            guard error == nil, !movieInfoList.movieInfoModel(0).DOCID.isEmpty else { completion(error); return }
            
            self?.movieInfoModel = movieInfoList.movieInfoModel(0)
            completion(nil)
        }
    }
    
    //MARK: - For CommentsViewController
    
    func loadAccountCommentList(completion: @escaping (Error?) -> Void) {
        accountCommentListModel = nil
        FBService.loadAccountCommentList { [weak self] accountCommentListModel, error in
            guard error == nil else { completion(error); return }
            self?.accountCommentListModel = accountCommentListModel
            completion(nil)
        }
    }
    
    func deleteComment(userId: String?, index: Int, completion: @escaping (Error?) -> Void) {
        let movieInfo = accountCommentListModel.accountCommentModel(index)
        FBService.deleteComment(collection: userId, document: movieInfo.DOCID) { error in completion(error) }
    }
}
