//
//  FirebaseStore.swift
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
    
    func loadCommentList(DOCID: String, completion: @escaping (CommentListModel, Float, Error?) -> Void) {
        
        db.collection(DOCID).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(CommentListModel([FBCommentModel.empty]), 0.0, error)
                return
            }
            
            var comments: [FBCommentModel] = []
            var gradeTotal: Float = 0.0
            var gradeCount: Float = 0.0
            var gradeAverage: Float = 0.0
            
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
                        
                        if !comment.isEmpty {
                            comments.append(FBCommentModel)
                        }
                        
                        gradeTotal += grade
                        gradeCount += 1
                    }
                }
                
                // 평균 평점
                if gradeCount != 0 {
                    gradeAverage = gradeTotal / gradeCount
                }
                
                completion(CommentListModel(comments), gradeAverage, nil)
            }
        }
    }
    
    func loadUserComment(DOCID: String, completion: @escaping (CommentModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
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
    
    func loadEstimateList(completion: @escaping (EstimateListModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
        db.collection(userId).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(EstimateListModel([FBEstimateModel.empty]), error)
                return
            }
            
            var FBEstimateModelList: [FBEstimateModel] = []
            
            if let snapshotDocuments = querySnapshot?.documents {
                
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let DOCID = data[K.FStore.DOCID] as? String,
                       let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let grade = data[K.FStore.grade] as? Float,
                       let comment = data[K.FStore.comment] as? String,
                       let date = data[K.FStore.date] as? String {
                        
                        let newItem = FBEstimateModel(DOCID: DOCID,
                                                      movieId: movieId,
                                                      movieSeq: movieSeq,
                                                      movieName: movieName,
                                                      thumbNailLink: thumbNailLink,
                                                      grade: grade,
                                                      comment: comment,
                                                      date: date)
                        
                        FBEstimateModelList.append(newItem)
                    }
                }
                completion(EstimateListModel(FBEstimateModelList), nil)
            }
        }
    }
    
    func loadWishToWatchList(completion: @escaping (WishToWatchListModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
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
                       let gradeAverage = data[K.FStore.gradeAverage] as? Float,
                       let wishToWatch = data[K.FStore.isWishToWatch] as? Bool,
                       let date = data[K.FStore.date] as? String {
                        
                        let newItem = FBWishToWatchModel(movieId: movieId,
                                                         movieSeq: movieSeq,
                                                         movieName: movieName,
                                                         thumbNailLink: thumbNailLink,
                                                         gradeAverage: gradeAverage,
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
        guard let userId = userId else { completion(false); return }
        db.collection(userId).document("\(K.FStore.isWishToWatch)\(DOCID)").addSnapshotListener { documentSnapshot, error in
            guard error == nil, let document = documentSnapshot else { completion(false); return }
            completion(document.exists ? true : false)  // true 인 경우에만 데이터가 존재 함
        }
    }
    
    func loadUserCommentList(completion: @escaping (EstimateListModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
        db.collection(userId).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(EstimateListModel([FBEstimateModel.empty]), error)
                return
            }
            
            var FBEstimateModelList: [FBEstimateModel] = []
            
            if let snapshotDocuments = querySnapshot?.documents {
                
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let DOCID = data[K.FStore.DOCID] as? String,
                       let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let grade = data[K.FStore.grade] as? Float,
                       let comment = data[K.FStore.comment] as? String,
                       let date = data[K.FStore.date] as? String,
                       !comment.isEmpty {
                        
                        let newItem = FBEstimateModel(DOCID: DOCID,
                                                      movieId: movieId,
                                                      movieSeq: movieSeq,
                                                      movieName: movieName,
                                                      thumbNailLink: thumbNailLink,
                                                      grade: grade,
                                                      comment: comment,
                                                      date: date)
                        
                        FBEstimateModelList.append(newItem)
                    }
                }
                completion(EstimateListModel(FBEstimateModelList), nil)
            }
        }
    }
    
    //MARK: - Create/ Update data methods
    
    // add 작업시 addComment()/ addAccountInfo() 한쌍임
    
    // collection: DOCID, document: userId
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
                                                       K.FStore.date: date]) { [weak self] error in
            
            guard error == nil else { completion(error); return }
            
            self?.addAccountInfo(userId: userId,
                                 DOCID: DOCID,
                                 movieId: movieId,
                                 movieSeq: movieSeq,
                                 movieName: movieName,
                                 thumbNailLink: thumbNailLink,
                                 grade: grade,
                                 comment: comment,
                                 date: date) { error in completion(error) }
        }
    }
    
    // collection: userId, document: DOCID
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
        
        db.collection(userId).document(DOCID).setData([K.FStore.DOCID: DOCID,
                                                       K.FStore.movieId: movieId,
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
                          gradeAverage: Float,
                          iswishToWatch: Bool,
                          completion: @escaping (Error?) -> Void) {
        
        guard let userId = self.userId else { completion(nil); return }
        
        guard iswishToWatch else {
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
                      K.FStore.gradeAverage: gradeAverage,
                      K.FStore.isWishToWatch: iswishToWatch,
                      K.FStore.date: date]) { error in completion(error) }
    }
    
    //MARK: - Delete data methods
    
    // delete 작업시 deleteComment()/ deletePairComment() 한쌍임
    func deleteComment(collection: String?, document: String?, completion: @escaping (Error?) -> Void) {
        guard let document = document, let collection = collection else { completion(nil); return }
        db.collection(collection).document(document).delete() { [weak self] error in
            guard error == nil else { completion(error); return }
            self?.deletePairComment(collection: document, document: collection) { error in completion(error) }
        }
    }
    
    private func deletePairComment(collection: String, document: String, completion: @escaping (Error?) -> Void) {
        db.collection(collection).document(document).delete() { error in completion(error) }
    }
    
    private func getFormattedDate() -> String {
        let date = Date()
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateformat.string(from: date)
    }
}
