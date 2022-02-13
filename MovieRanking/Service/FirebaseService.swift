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
    
    func loadCurrentUserComment(DOCID: String, completion: @escaping (CommentModel, Error?) -> Void) {
        
        guard let userId = self.userId else { return }
        
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
    
    func loadCurrentUserCommentList(completion: @escaping (CurrentUserCommentListModel, Error?) -> Void) {
        
        guard let userId = self.userId else {
            completion(CurrentUserCommentListModel([FBCurrentUserCommentModel.empty]), nil)
            return
        }
        
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
    
    func loadWishToWatchList(completion: @escaping (WishToWatchListModel, Error?) -> Void) {
        
        guard let userId = self.userId else { completion(WishToWatchListModel([FBWishToWatchModel.empty]), nil); return }
        
        db.collection(userId).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else { completion(WishToWatchListModel([FBWishToWatchModel.empty]), error); return }
            
            var wishToWatchList: [FBWishToWatchModel] = []
            
            if let snapshotDocuments = querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let wishToWatch = data[K.FStore.wishToWatch] as? Bool,
                       let date = data[K.FStore.date] as? String {
                        
                        let newItem = FBWishToWatchModel(movieId: movieId,
                                                       movieSeq: movieSeq,
                                                       movieName: movieName,
                                                       thumbNailLink: thumbNailLink,
                                                       wishToWatch: wishToWatch,
                                                       date: date)
                        wishToWatchList.append(newItem)
                    }
                }
                completion(WishToWatchListModel(wishToWatchList), nil)
            }
        }
    }
}
