//
//  FirebaseViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import Foundation

class FirebaseViewModel {
    
    private let service = FirebaseService()
    
    var commentListModel: CommentListModel!
    var currentUserComment: CommentModel!
    var currentUserCommentListModel: CurrentUserCommentListModel!
    var wishToWatchListModel: WishToWatchListModel!
    
    var gradeAverage: Float = 0.0
    var isWishToWatch: Bool = false
    
    var commentCount: Int {
        return (commentListModel == nil || commentListModel.count == 0) ? 1 : commentListModel.count
    }
    
    var IsCommentExist: Bool {
        return (commentListModel == nil || commentListModel.count == 0) ? false : true
    }
    
    var currentUserCommentCount: Int {
        return currentUserCommentListModel == nil ? 0 : currentUserCommentListModel.count
    }
    
    var wishToWatchListCount: Int {
        return wishToWatchListModel == nil ? 0 : wishToWatchListModel.count
    }
    
    var userId: String? {
        return service.userId
    }
    
    func register(email: String, password: String, completion: @escaping (Error?) -> Void) {
        service.register(email: email, password: password) { error in completion(error) }
    }
    
    func logIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        service.logIn(email: email, password: password) { error in completion(error) }
    }
    
    func logOut(completion: @escaping (Error?) -> Void) {
        service.logOut { error in
            guard error == nil else { completion(error); return }
            completion(nil)
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
            let movieInfo = currentUserCommentListModel.currentUserCommentModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        }
        return (movieId, movieSeq)
    }
    
    //MARK: - Load data methods
    
    func loadComment(DOCID: String, completion: @escaping (Error?) -> Void) {
        commentListModel = nil
        service.loadComment(DOCID: DOCID) { [weak self] commentListModel, gradeAverage, error in
            guard error == nil else { completion(error); return }
            self?.commentListModel = commentListModel
            self?.gradeAverage = gradeAverage
            completion(nil)
        }
    }
    
    func loadCurrentUserComment(DOCID: String, completion: @escaping (Error?) -> Void) {
        currentUserComment = nil
        service.loadCurrentUserComment(DOCID: DOCID) { [weak self] currentUserComment, error in
            guard error == nil else { completion(error); return }
            self?.currentUserComment = currentUserComment
            completion(nil)
        }
    }
    
    
    func loadCurrentUserCommentList(completion: @escaping (Error?) -> Void) {
        currentUserCommentListModel = nil
        service.loadCurrentUserCommentList { [weak self] currentUserCommentListModel, error in
            guard error == nil else { completion(error); return }
            self?.currentUserCommentListModel = currentUserCommentListModel
            completion(nil)
        }
    }
    
    func loadWishToWatchList(completion: @escaping (Error?) -> Void) {
        wishToWatchListModel = nil
        service.loadWishToWatchList { [weak self] wishToWatchListModel, error in
            guard error == nil else { completion(error); return }
            self?.wishToWatchListModel = wishToWatchListModel
            completion(nil)
        }
    }
    
    func loadIsWishToWatch(DOCID: String, completion: @escaping () -> Void) {
        isWishToWatch = false
        service.loadIsWishToWatch(DOCID: DOCID) { [weak self] isWishToWatch in
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
        
        service.addComment(DOCID: DOCID,
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
        
        service.setIsWishToWatch(DOCID: DOCID,
                                 movieId: movieId,
                                 movieSeq: movieSeq,
                                 movieName: movieName,
                                 thumbNailLink: thumbNailLink,
                                 gradeAverage: gradeAverage,
                                 wishToWatch: wishToWatch) { error in completion(error) }
    }
    
    //MARK: - Delete data methods
    
    func deleteComment(DOCID: String, userId: String, completion: @escaping (Error?) -> Void) {
        service.deleteComment(DOCID: DOCID, userId: userId) { error in completion(error) }
    }
}
