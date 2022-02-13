//
//  FirebaseViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import Firebase

class FirebaseViewModel {
    
    private let db = Firestore.firestore()
    private let service = FirebaseService()
    
    var commentListModel: CommentListModel!
    var currentUserComment: CommentModel?
    var currentUserCommentListModel: CurrentUserCommentListModel!
    var wishToWatchListModel: WishToWatchListModel!
    
    var gradeAverage: Float = 0.0
    
    var numberOfRowsInSectionForComment: Int {
        return commentListModel == nil ? 1 : commentListModel.count
    }
    
    var numberOfRowsInSectionForCurrentUserComment: Int {
        return currentUserCommentListModel == nil ? 0 : currentUserCommentListModel.count
    }
    
    var numberOfRowsInSectionForWishToWatchList: Int {
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
        service.logOut { [weak self] error in
            guard error == nil else { completion(error); return }
            self?.currentUserCommentListModel = nil
            self?.wishToWatchListModel = nil
            completion(nil)
        }
    }
    
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
    
    func addWishToWatchList(DOCID: String,
                           movieId: String,
                           movieSeq: String,
                           movieName: String,
                           thumbNailLink: String,
                           wishToWatch: Bool,
                           completion: @escaping (Error?) -> Void) {
        
        guard let userId = self.userId else { completion(nil); return }
        
        if wishToWatch {
            let date = getFormattedDate()
            
            db.collection(userId).document("\(K.FStore.wishToWatch)\(DOCID)").setData([K.FStore.movieId: movieId,
                                                                                       K.FStore.movieSeq : movieSeq,
                                                                                       K.FStore.movieName: movieName,
                                                                                       K.FStore.thumbNailLink: thumbNailLink,
                                                                                       K.FStore.wishToWatch: wishToWatch,
                                                                                       K.FStore.date: date]) { error in
                completion(error)
            }
            
        } else {
            db.collection(userId).document("\(K.FStore.wishToWatch)\(DOCID)").delete() { error in
                completion(error)
            }
        }
    }
    
    func getWishToWatchInfo(DOCID: String, completion: @escaping (Bool) -> Void) {
        guard let userId = self.userId else { completion(false); return }
        
        db.collection(userId).document("\(K.FStore.wishToWatch)\(DOCID)").addSnapshotListener { documentSnapshot, error in
            
            guard error == nil, let document = documentSnapshot else { completion(false); return }

            completion(document.exists ? true : false)
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
        
        guard let userId = self.userId else { completion(nil); return }
        
        let date = getFormattedDate()
        
        db.collection(DOCID).document(userId).setData([K.FStore.userId : userId,
                                                       K.FStore.movieName: movieName,
                                                       K.FStore.grade : grade,
                                                       K.FStore.comment: comment,
                                                       K.FStore.date: date]) { error in
            
            completion(error)
        }
        
        // 서비스 제공을 위한 데이터 저장: collection() <----> document() Field Name 바꿔서 저장
        addAccountInfo(userId: userId,
                       DOCID: DOCID,
                       movieId: movieId,
                       movieSeq: movieSeq,
                       movieName: movieName,
                       thumbNailLink: thumbNailLink,
                       grade: grade,
                       comment: comment,
                       date: date)
    }
    
    private func addAccountInfo(userId: String,
                                DOCID: String,
                                movieId: String,
                                movieSeq: String,
                                movieName: String,
                                thumbNailLink: String,
                                grade: Float,
                                comment: String,
                                date: String) {
        
        db.collection(userId).document(DOCID).setData([K.FStore.movieId: movieId,
                                                       K.FStore.movieSeq : movieSeq,
                                                       K.FStore.movieName: movieName,
                                                       K.FStore.thumbNailLink: thumbNailLink,
                                                       K.FStore.grade : grade,
                                                       K.FStore.comment: comment,
                                                       K.FStore.date: date]) { _ in }
    }
    
    func deleteComment(DOCID: String, userId: String, completion: @escaping (Error?) -> Void) {
        
        guard let userId = self.userId else { completion(nil); return }
        db.collection(DOCID).document(userId).delete() { error in
            completion(error)
        }
        
        deleteAccountInfo(userId: userId, DOCID: DOCID)
    }
    
    private func deleteAccountInfo(userId: String, DOCID: String) {
        db.collection(userId).document(DOCID).delete() { _ in }
    }
    
    private func getFormattedDate() -> String {
        let date = Date()
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateformat.string(from: date)
    }
}
