//
//  MovieInfoViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/05.
//

import Foundation

class MovieInfoViewModel {
    
    var onUpdated: () -> Void = {}
    
    private let service = MovieInformationService()
    private let FBService = FirebaseService()
    
    //MARK: - MovieInformationService
    
    var movieInfoModel: MovieInfoModel!
    
    var movieInfoList: MovieInfoListModel! {
        didSet {
            onUpdated()
        }
    }
    
    var numberOfSections: Int {
        return movieInfoList == nil ? 0 : 1
    }
    
    var numberOfRowsInSection: Int {
        return movieInfoList == nil ? 0 : movieInfoList.count
    }
    
    func heightForHeader(by section: Int) -> Float {
        var height: Float = 0.0
        switch section {
        case 0:
            height = 0
        case 1:
            height = 0
        default:
            height = 3
        }
        return height
    }
    
    func clearMovieInfoList() {
        movieInfoList = nil
    }
    
    // 영화별 정보 상세 - 한국영화데이터베이스
    func fetchMovieInfo(title movieName: String, completion: @escaping (Error?) -> Void) {
        movieInfoList = nil
        
        service.fetchMovieInfo(title: movieName) { [weak self] movieInfoList, error in
            guard error == nil, !movieInfoList.movieInfoModel(0).DOCID.isEmpty else { completion(error); return }
            
            self?.movieInfoList = movieInfoList
            completion(nil)
        }
    }
    
    //MARK: - FirestoreService
    
    var commentListModel: CommentListModel!
    var userComment: CommentModel!
    
    var gradeAverage: Float = 0.0
    var isWishToWatch: Bool = false
    
    var userId: String? {
        return FBService.userId
    }
    
    private var commentCount: Int {
        return (commentListModel == nil || commentListModel.count == 0) ? 1 : commentListModel.count
    }
    
    var IsCommentExist: Bool {
        return (commentListModel == nil || commentListModel.count == 0) ? false : true
    }
    
    func sectionCount(by section: Int) -> Int {
        switch section {
        case 6:
            return commentCount
        default:
            return 1
        }
    }
    
    func loadCommentList(DOCID: String, completion: @escaping (Error?) -> Void) {
        commentListModel = nil
        FBService.loadCommentList(DOCID: DOCID) { [weak self] commentListModel, gradeAverage, error in
            guard error == nil else { completion(error); return }
            self?.commentListModel = commentListModel
            self?.gradeAverage = gradeAverage
            completion(nil)
        }
    }
    
    func loadUserComment(DOCID: String, completion: @escaping (Error?) -> Void) {
        userComment = nil
        FBService.loadUserComment(DOCID: DOCID) { [weak self] userComment, error in
            guard error == nil else { completion(error); return }
            self?.userComment = userComment
            completion(nil)
        }
    }
    
    func loadIsWishToWatch(DOCID: String, completion: @escaping () -> Void) {
        isWishToWatch = false
        FBService.loadIsWishToWatch(DOCID: DOCID) { [weak self] isWishToWatch in
            self?.isWishToWatch = isWishToWatch
            completion()
        }
    }
    
    func addComment(DOCID: String,
                    movieId: String,
                    movieSeq: String,
                    movieName: String,
                    thumbNailLink: String,
                    grade: Float,
                    comment: String,
                    completion: @escaping (Error?) -> Void) {
        
        FBService.addComment(DOCID: DOCID,
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
        
        FBService.setIsWishToWatch(DOCID: DOCID,
                                 movieId: movieId,
                                 movieSeq: movieSeq,
                                 movieName: movieName,
                                 thumbNailLink: thumbNailLink,
                                 gradeAverage: gradeAverage,
                                 iswishToWatch: wishToWatch) { error in completion(error) }
    }
    
    func deleteComment(DOCID: String, userId: String, completion: @escaping (Error?) -> Void) {
        FBService.deleteComment(collection: DOCID, document: userId) { error in completion(error) }
    }
}
