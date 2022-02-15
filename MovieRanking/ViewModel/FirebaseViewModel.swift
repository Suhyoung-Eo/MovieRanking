//
//  FirebaseViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import Foundation

class FirebaseViewModel {
    
    private let FBStore = FirebaseStore()
    
    var commentListModel: CommentListModel!
    var userComment: CommentModel!
    var estimateListModel: EstimateListModel!
    var wishToWatchListModel: WishToWatchListModel!
    
    var gradeAverage: Float = 0.0
    var isWishToWatch: Bool = false
    
    var commentCount: Int {
        return (commentListModel == nil || commentListModel.count == 0) ? 1 : commentListModel.count
    }
    
    var IsCommentExist: Bool {
        return (commentListModel == nil || commentListModel.count == 0) ? false : true
    }
    
    var EstimateListCount: Int {
        return estimateListModel == nil ? 0 : estimateListModel.count
    }
    
    var wishToWatchListCount: Int {
        return wishToWatchListModel == nil ? 0 : wishToWatchListModel.count
    }
    
    var userId: String? {
        return FBStore.userId
    }
    
    func register(email: String, password: String, completion: @escaping (Error?) -> Void) {
        FBStore.register(email: email, password: password) { error in completion(error) }
    }
    
    func logIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        FBStore.logIn(email: email, password: password) { error in completion(error) }
    }
    
    func logOut(completion: @escaping (Error?) -> Void) {
        FBStore.logOut { error in
            guard error == nil else { completion(error); return }
            completion(nil)
        }
    }
    
    //MARK: - For MovieInfoViewController methods
    func sectionCount(by section: Int) -> Int {
        switch section {
        case 6:
            return commentCount
        default:
            return 1
        }
    }

    //MARK: - For StorageViewController methods
    
    func setMovieInfo(by itemTitle: String, index: Int) -> (String, String) {
        var movieId: String = ""
        var movieSeq: String = ""
        
        if itemTitle == K.Prepare.wishToWatchView {
            let movieInfo = wishToWatchListModel.wishToWatchListModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        }
        else {
            let movieInfo = estimateListModel.estimateModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        }
        return (movieId, movieSeq)
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
    
    //MARK: - Load data methods
    
    func loadComment(DOCID: String, completion: @escaping (Error?) -> Void) {
        commentListModel = nil
        FBStore.loadComment(DOCID: DOCID) { [weak self] commentListModel, gradeAverage, error in
            guard error == nil else { completion(error); return }
            self?.commentListModel = commentListModel
            self?.gradeAverage = gradeAverage
            completion(nil)
        }
    }
    
    func loadUserComment(DOCID: String, completion: @escaping (Error?) -> Void) {
        userComment = nil
        FBStore.loadUserComment(DOCID: DOCID) { [weak self] userComment, error in
            guard error == nil else { completion(error); return }
            self?.userComment = userComment
            completion(nil)
        }
    }
    
    
    func loadEstimateList(completion: @escaping (Error?) -> Void) {
        estimateListModel = nil
        FBStore.loadEstimateList { [weak self] estimateListModel, error in
            guard error == nil else { completion(error); return }
            self?.estimateListModel = estimateListModel
            completion(nil)
        }
    }
    
    func loadWishToWatchList(completion: @escaping (Error?) -> Void) {
        wishToWatchListModel = nil
        FBStore.loadWishToWatchList { [weak self] wishToWatchListModel, error in
            guard error == nil else { completion(error); return }
            self?.wishToWatchListModel = wishToWatchListModel
            completion(nil)
        }
    }
    
    func loadIsWishToWatch(DOCID: String, completion: @escaping () -> Void) {
        isWishToWatch = false
        FBStore.loadIsWishToWatch(DOCID: DOCID) { [weak self] isWishToWatch in
            self?.isWishToWatch = isWishToWatch
            completion()
        }
    }
    
    //MARK: - Update/ Set data methods
    
    func addComment(DOCID: String,
                    movieId: String,
                    movieSeq: String,
                    movieName: String,
                    thumbNailLink: String,
                    grade: Float,
                    comment: String,
                    completion: @escaping (Error?) -> Void) {
        
        FBStore.addComment(DOCID: DOCID,
                           movieId: movieId,
                           movieSeq: movieSeq,
                           movieName: movieName,
                           thumbNailLink: thumbNailLink,
                           grade: grade,
                           comment: comment) { error in  completion(error) }
    }
    
    func setIsWishToWatch(DOCID: String,
                          movieId: String,
                          movieSeq: String,
                          movieName: String,
                          thumbNailLink: String,
                          gradeAverage: Float,
                          wishToWatch: Bool,
                          completion: @escaping (Error?) -> Void) {
        
        FBStore.setIsWishToWatch(DOCID: DOCID,
                                 movieId: movieId,
                                 movieSeq: movieSeq,
                                 movieName: movieName,
                                 thumbNailLink: thumbNailLink,
                                 gradeAverage: gradeAverage,
                                 wishToWatch: wishToWatch) { error in completion(error) }
    }
    
    //MARK: - Delete data methods
    
    func deleteComment(DOCID: String, userId: String, completion: @escaping (Error?) -> Void) {
        FBStore.deleteComment(DOCID: DOCID, userId: userId) { error in completion(error) }
    }
}
