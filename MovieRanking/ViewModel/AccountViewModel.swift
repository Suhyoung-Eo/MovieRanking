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
    var estimateListModel: EstimateListModel!
    var userCommentListModel: EstimateListModel!
    var wishToWatchListModel: WishToWatchListModel!
    
    var userId: String? {
        return FBService.userId
    }
    
    //MARK: - For StorageViewController
    
    var EstimateListCount: Int {
        return estimateListModel == nil ? 0 : estimateListModel.count
    }
    
    var wishToWatchListCount: Int {
        return wishToWatchListModel == nil ? 0 : wishToWatchListModel.count
    }
    
    func storageNumberOfItems(by title: String) -> Int {
        switch title {
        case K.Prepare.wishToWatchView:
            return wishToWatchListCount
        case K.Prepare.estimateView:
            return EstimateListCount
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
    
    func loadEstimateList(completion: @escaping (Error?) -> Void) {
        estimateListModel = nil
        FBService.loadEstimateList { [weak self] estimateListModel, error in
            guard error == nil else { completion(error); return }
            self?.estimateListModel = estimateListModel
            completion(nil)
        }
    }
    
    func loadMovieInfo(by itemTitle: String, index: Int, completion: @escaping (Error?) -> Void) {
        movieInfoModel = nil
        var movieId: String = ""
        var movieSeq: String = ""
        
        switch itemTitle {
        case K.Prepare.wishToWatchView:
            let movieInfo = wishToWatchListModel.wishToWatchListModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        case K.Prepare.estimateView:
            let movieInfo = estimateListModel.estimateModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        case K.Prepare.userCommentView:
            let movieInfo = userCommentListModel.estimateModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        default:
            completion(nil)
        }

        movieInfoService.fetchMovieInfo(id: movieId, seq: movieSeq) { [weak self] movieInfoList, error in
            guard error == nil, !movieInfoList.movieInfoModel(0).DOCID.isEmpty else { completion(error); return }
            
            self?.movieInfoModel = movieInfoList.movieInfoModel(0)
            completion(nil)
        }
    }
    
    //MARK: - For CommentsViewController
    
    var userCommentListCount: Int {
        return userCommentListModel == nil ? 0 : userCommentListModel.count
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
    
    func loadUserCommentList(completion: @escaping (Error?) -> Void) {
        userCommentListModel = nil
        FBService.loadUserCommentList { [weak self] userCommentListModel, error in
            guard error == nil else { completion(error); return }
            self?.userCommentListModel = userCommentListModel
            completion(nil)
        }
    }
        
    func deleteComment(userId: String?, index: Int, completion: @escaping (Error?) -> Void) {
        let movieInfo = userCommentListModel.estimateModel(index)
        FBService.deleteComment(collection: userId, document: movieInfo.DOCID) { error in completion(error) }
    }
}
