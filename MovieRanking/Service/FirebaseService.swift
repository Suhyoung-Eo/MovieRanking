//
//  FirebaseService.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/13.
//

import Firebase

class FirebaseService {
    
    private let db = Firestore.firestore()
    
    var userId: String? {
        return Auth.auth().currentUser?.email
    }
    
    func register(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            guard error == nil else { completion(error); return }
            completion(nil)
        }
    }
    
    func logIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            guard error == nil else { completion(error); return }
            completion(nil)
        }
    }
    
    func logOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    
    //MARK: - Read data methods
    
    func loadComment(DOCID: String, completion: @escaping (CommentListModel, Float, Error?) -> Void) {
        
        db.collection(DOCID).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(CommentListModel([FBCommentModel.empty]), 0.0, error)
                return
            }
            
            var comments: [FBCommentModel] = []
            var gradeTotal: Float = 0.0
            var gradeAverage: Float = 0
            
            if let snapshotDocuments = querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let userId = data[K.FStore.userId] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let grade = data[K.FStore.grade] as? Float,
                       let comment = data[K.FStore.comment] as? String,
                       let date = data[K.FStore.date] as? String {
                        
                        let FBCommentModel = FBCommentModel(userId: userId,
                                                            movieName: movieName,
                                                            grade: grade,
                                                            comment: comment,
                                                            date: date)
                        comments.append(FBCommentModel)
                    }
                }
                
                // 평균 평점
                if comments.count == 0 {
                    gradeAverage = 0
                } else {
                    for comment in comments {
                        gradeTotal += comment.grade
                    }
                    gradeAverage = gradeTotal / Float(comments.count)
                }
                
                completion(CommentListModel(comments), gradeAverage, nil)
            }
        }
    }
    
    func loadCurrentUserComment(DOCID: String, completion: @escaping (CommentModel?, Error?) -> Void) {
        
        guard let userId = self.userId else { completion(nil, nil); return }
        
        db.collection(DOCID).document(userId).addSnapshotListener { documentSnapshot, error in
            
            guard error == nil, let document = documentSnapshot, let data = document.data() else {
                completion(CommentModel(FBCommentModel.empty), error)
                return
            }
            
            if let userId = data[K.FStore.userId] as? String,
               let movieName = data[K.FStore.movieName] as? String,
               let grade = data[K.FStore.grade] as? Float,
               let comment = data[K.FStore.comment] as? String,
               let date = data[K.FStore.date] as? String {
                
                let FBCommentModel = FBCommentModel(userId: userId,
                                                    movieName: movieName,
                                                    grade: grade,
                                                    comment: comment,
                                                    date: date)
                
                completion(CommentModel(FBCommentModel), nil)
            }
        }
    }
    
    func loadCurrentUserCommentList(completion: @escaping (CurrentUserCommentListModel?, Error?) -> Void) {
        
        guard let userId = self.userId else { completion(nil, nil); return }
        
        db.collection(userId).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(CurrentUserCommentListModel([FBCurrentUserCommentModel.empty]), error)
                return
            }
            
            var CurrentUserComments: [FBCurrentUserCommentModel] = []
            
            if let snapshotDocuments = querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let grade = data[K.FStore.grade] as? Float,
                       let comment = data[K.FStore.comment] as? String,
                       let date = data[K.FStore.date] as? String {
                        
                        let newItem = FBCurrentUserCommentModel(movieId: movieId,
                                                                movieSeq: movieSeq,
                                                                movieName: movieName,
                                                                thumbNailLink: thumbNailLink,
                                                                grade: grade,
                                                                comment: comment,
                                                                date: date)
                        CurrentUserComments.append(newItem)
                    }
                }
                completion(CurrentUserCommentListModel(CurrentUserComments), nil)
            }
        }
    }
    
    func loadWishToWatchList(completion: @escaping (WishToWatchListModel?, Error?) -> Void) {
        
        guard let userId = self.userId else { completion(nil, nil); return }
        
        db.collection(userId).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(WishToWatchListModel([FBWishToWatchModel.empty]), error)
                return
            }
            
            var wishToWatchList: [FBWishToWatchModel] = []
            
            if let snapshotDocuments = querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let wishToWatch = data[K.FStore.isWishToWatch] as? Bool,
                       let date = data[K.FStore.date] as? String {
                        
                        let newItem = FBWishToWatchModel(movieId: movieId,
                                                         movieSeq: movieSeq,
                                                         movieName: movieName,
                                                         thumbNailLink: thumbNailLink,
                                                         isWishToWatch: wishToWatch,
                                                         date: date)
                        wishToWatchList.append(newItem)
                    }
                }
                completion(WishToWatchListModel(wishToWatchList), nil)
            }
        }
    }
    
    func loadIsWishToWatch(DOCID: String, completion: @escaping (Bool) -> Void) {
        guard let userId = self.userId else { completion(false); return }
        db.collection(userId).document("\(K.FStore.isWishToWatch)\(DOCID)").addSnapshotListener { documentSnapshot, error in
            guard error == nil, let document = documentSnapshot else { completion(false); return }
            completion(document.exists ? true : false)  // true 인 경우에만 데이터가 존재 함
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
        
        guard let userId = self.userId else { completion(nil); return }
        
        let date = getFormattedDate()
        
        db.collection(DOCID).document(userId).setData([K.FStore.userId : userId,
                                                       K.FStore.movieName: movieName,
                                                       K.FStore.grade : grade,
                                                       K.FStore.comment: comment,
                                                       K.FStore.date: date]) { error in completion(error) }
        
        // 서비스 제공을 위한 데이터 저장: collection() <----> document() Field Name 바꿔서 저장
        addAccountInfo(userId: userId,
                       DOCID: DOCID,
                       movieId: movieId,
                       movieSeq: movieSeq,
                       movieName: movieName,
                       thumbNailLink: thumbNailLink,
                       grade: grade,
                       comment: comment,
                       date: date) { error in completion(error) }
    }
    
    private func addAccountInfo(userId: String,
                                DOCID: String,
                                movieId: String,
                                movieSeq: String,
                                movieName: String,
                                thumbNailLink: String,
                                grade: Float,
                                comment: String,
                                date: String,
                                completion: @escaping (Error?) -> Void) {
        
        db.collection(userId).document(DOCID).setData([K.FStore.movieId: movieId,
                                                       K.FStore.movieSeq : movieSeq,
                                                       K.FStore.movieName: movieName,
                                                       K.FStore.thumbNailLink: thumbNailLink,
                                                       K.FStore.grade : grade,
                                                       K.FStore.comment: comment,
                                                       K.FStore.date: date]) { error in completion(error) }
    }
    
    func setIsWishToWatch(DOCID: String,
                          movieId: String,
                          movieSeq: String,
                          movieName: String,
                          thumbNailLink: String,
                          wishToWatch: Bool,
                          completion: @escaping (Error?) -> Void) {
        
        guard let userId = self.userId else { completion(nil); return }
        
        guard wishToWatch else {
            db.collection(userId).document("\(K.FStore.isWishToWatch)\(DOCID)")
                .delete() { error in completion(error) }
            return
        }
        
        let date = getFormattedDate()
        
        db.collection(userId).document("\(K.FStore.isWishToWatch)\(DOCID)")
            .setData([K.FStore.movieId: movieId,
                      K.FStore.movieSeq : movieSeq,
                      K.FStore.movieName: movieName,
                      K.FStore.thumbNailLink: thumbNailLink,
                      K.FStore.isWishToWatch: wishToWatch,
                      K.FStore.date: date]) { error in completion(error) }
    }
    
    //MARK: - Delete data methods
    
    func deleteComment(DOCID: String, userId: String, completion: @escaping (Error?) -> Void) {
        guard let userId = self.userId else { completion(nil); return }
        db.collection(DOCID).document(userId).delete() { error in completion(error) }
        deleteUserComment(userId: userId, DOCID: DOCID)
    }
    
    private func deleteUserComment(userId: String, DOCID: String) {
        db.collection(userId).document(DOCID).delete() { _ in }
    }
    
    private func getFormattedDate() -> String {
        let date = Date()
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateformat.string(from: date)
    }
}
