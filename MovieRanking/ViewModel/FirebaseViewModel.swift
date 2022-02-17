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
    var userComment: CommentModel!
    
    var userId: String? {
        return service.userId
    }
    
    //MARK: - For MovieInfoViewController
    
    var gradeAverage: Float = 0.0
    var isWishToWatch: Bool = false
    
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

    //MARK: - Read data methods
    
    func loadCommentList(DOCID: String, completion: @escaping (Error?) -> Void) {
        commentListModel = nil
        service.loadCommentList(DOCID: DOCID) { [weak self] commentListModel, gradeAverage, error in
            guard error == nil else { completion(error); return }
            self?.commentListModel = commentListModel
            self?.gradeAverage = gradeAverage
            completion(nil)
        }
    }
    
    func loadUserComment(DOCID: String, completion: @escaping (Error?) -> Void) {
        userComment = nil
        service.loadUserComment(DOCID: DOCID) { [weak self] userComment, error in
            guard error == nil else { completion(error); return }
            self?.userComment = userComment
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
    
    //MARK: - Create/ Update data methods
    
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
                                 iswishToWatch: wishToWatch) { error in completion(error) }
    }
    
    //MARK: - Delete data method
    
    func deleteComment(DOCID: String, userId: String, completion: @escaping (Error?) -> Void) {
        service.deleteComment(collection: DOCID, document: userId) { error in completion(error) }
    }
}
