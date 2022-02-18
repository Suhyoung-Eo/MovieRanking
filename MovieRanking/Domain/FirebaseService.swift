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
    
    func loadGradeAverage(DOCID: String, completion: @escaping (Float, Error?) -> Void) {
        
        db.collection(DOCID).getDocuments() { [weak self] querySnapshot, error in
            guard error == nil else { completion(0.0, error); return }
            
            var gradeTotal: Float = 0.0
            var gradeCount: Float = 0.0
            var gradeAverage: Float = 0.0
            
            if let snapshotDocuments = querySnapshot?.documents {
                
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let grade = data[K.FStore.grade] as? Float {
                        gradeTotal += grade
                        gradeCount += 1
                    }
                }
                
                // 평균 평점
                if gradeCount != 0 {
                    gradeAverage = gradeTotal / gradeCount
                }
                
                if let userId = self?.userId {
                    self?.db.collection(userId).document(DOCID).setData([K.FStore.gradeAverage: gradeAverage], merge: true) { error in
                        completion(gradeAverage, error)
                    }
                } else {
                    completion(gradeAverage, error)
                }
            }
        }
    }
    
    func loadIsWishToWatch(DOCID: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else { completion(false, nil); return }
        db.collection(userId).document(DOCID).getDocument() { documentSnapshot, error in
            guard error == nil, let document = documentSnapshot else { completion(false, error); return }
            
            if let data = document.data(), let isWishToWatch = data[K.FStore.wishToWatch] as? Bool {
                completion(isWishToWatch, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func loadUserComment(DOCID: String, completion: @escaping (Float, String, Error?) -> Void) {
        
        guard let userId = userId else { completion(0, "",nil); return }
        
        db.collection(DOCID).document(userId).getDocument() { documentSnapshot, error in
            
            guard error == nil, let document = documentSnapshot, let data = document.data() else {
                completion(0, "",error)
                return
            }
            
            if let comment = data[K.FStore.comment] as? String,
               let grade = data[K.FStore.grade] as? Float {
                completion(grade, comment, nil)
            } else if let grade = data[K.FStore.grade] as? Float {
                completion(grade, "", nil)
            } else {
                completion(0, "", nil)
            }
        }
    }
    
    func loadCommentList(DOCID: String, completion: @escaping (CommentListModel, Error?) -> Void) {
        
        db.collection(DOCID).order(by: K.FStore.date, descending: true).getDocuments() { querySnapshot, error in
            
            guard error == nil else { completion(CommentListModel([FBCommentModel.empty]), error); return }
            
            var FBCommentModelList: [FBCommentModel] = []
            
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
                            FBCommentModelList.append(FBCommentModel)
                        }
                    }
                }
                completion(CommentListModel(FBCommentModelList), nil)
            }
        }
    }
    
    func loadWishToWatchList(completion: @escaping (WishToWatchListModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
        db.collection(userId).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(WishToWatchListModel([FBWishToWatchModel.empty]), error)
                return
            }
            
            var FBWishToWatchList: [FBWishToWatchModel] = []
            
            if let snapshotDocuments = querySnapshot?.documents {
                
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let gradeAverage = data[K.FStore.gradeAverage] as? Float,
                       let isWishToWatch = data[K.FStore.wishToWatch] as? Bool,
                       isWishToWatch {
                        
                        let newItem = FBWishToWatchModel(movieId: movieId,
                                                         movieSeq: movieSeq,
                                                         movieName: movieName,
                                                         thumbNailLink: thumbNailLink,
                                                         gradeAverage: gradeAverage,
                                                         isWishToWatch: isWishToWatch)
                        
                        FBWishToWatchList.append(newItem)
                    }
                }
                completion(WishToWatchListModel(FBWishToWatchList), nil)
            }
        }
    }
    
    func loadGradeList(completion: @escaping (GradeListModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
        db.collection(userId).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(GradeListModel([FBGradeModel.empty]), error)
                return
            }
            
            var FBGradeModelList: [FBGradeModel] = []
            
            if let snapshotDocuments = querySnapshot?.documents {
                
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let DOCID = data[K.FStore.DOCID] as? String,
                       let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let grade = data[K.FStore.grade] as? Float {
                        
                        let newItem = FBGradeModel(DOCID: DOCID,
                                                   movieId: movieId,
                                                   movieSeq: movieSeq,
                                                   movieName: movieName,
                                                   thumbNailLink: thumbNailLink,
                                                   grade: grade)
                        
                        FBGradeModelList.append(newItem)
                    }
                }
                completion(GradeListModel(FBGradeModelList), nil)
            }
        }
    }
    
    func loadAccountCommentList(completion: @escaping (AccountCommentListModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
        db.collection(userId).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(AccountCommentListModel([FBAccountCommentModel.empty]), error)
                return
            }
            
            var FBUserCommentList: [FBAccountCommentModel] = []
            
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
                        
                        let newItem = FBAccountCommentModel(DOCID: DOCID,
                                                            movieId: movieId,
                                                            movieSeq: movieSeq,
                                                            movieName: movieName,
                                                            thumbNailLink: thumbNailLink,
                                                            grade: grade,
                                                            comment: comment,
                                                            date: date)
                        
                        FBUserCommentList.append(newItem)
                    }
                }
                completion(AccountCommentListModel(FBUserCommentList), nil)
            }
        }
    }
    
    //MARK: - Create/ Update data methods
    
    func addComment(DOCID: String, grade: Float, comment: String, completion: @escaping (Error?) -> Void) {
        
        guard let userId = self.userId else { completion(nil); return }
        
        let date = getFormattedDate()
        
        if comment.isEmpty {
            db.collection(DOCID).document(userId).setData([K.FStore.userId : userId,
                                                           K.FStore.grade : grade]
                                                          , merge: true) { [weak self] error in
                
                guard error == nil else { completion(error); return }
                self?.db.collection(userId).document(DOCID).setData([K.FStore.grade: grade], merge: true)
                completion(error)
            }
        } else {
            db.collection(DOCID).document(userId).setData([K.FStore.userId : userId,
                                                           K.FStore.grade : grade,
                                                           K.FStore.comment: comment,
                                                           K.FStore.date: date]
                                                          , merge: true) { [weak self] error in
                
                guard error == nil else { completion(error); return }
                self?.db.collection(userId).document(DOCID).setData([K.FStore.grade: grade,
                                                                     K.FStore.comment: comment,
                                                                     K.FStore.date: date], merge: true)
                completion(error)
            }
        }
    }
    
    func setDataForAccount(movieInfo: MovieInfoModel, completion: @escaping (Error?) -> Void) {
        guard let userId = self.userId else { completion(nil); return }
        db.collection(userId).document(movieInfo.DOCID).setData([K.FStore.DOCID: movieInfo.DOCID,
                                                                 K.FStore.movieId: movieInfo.movieId,
                                                                 K.FStore.movieSeq : movieInfo.movieSeq,
                                                                 K.FStore.movieName: movieInfo.movieName,
                                                                 K.FStore.thumbNailLink: movieInfo.thumbNailLinks[0]]
                                                                , merge: true) { error in completion(error) }
        
    }
    
    func setIsWishToWatch(DOCID: String, isWishToWatch: Bool, completion: @escaping (Error?) -> Void) {
        guard let userId = self.userId else { completion(nil); return }
        db.collection(userId).document(DOCID).setData([K.FStore.wishToWatch: isWishToWatch], merge: true) { error in completion(error) }
    }
    
    //MARK: - Delete data methods
    
    func deleteComment(collection: String?, document: String?, completion: @escaping (Error?) -> Void) {
        guard let document = document, let collection = collection else { completion(nil); return }
        db.collection(collection).document(document).updateData([K.FStore.comment: FieldValue.delete(),
                                                                 K.FStore.date: FieldValue.delete()]) { [weak self] error in
            
            guard error == nil else { completion(error); return }
            
            self?.db.collection(document).document(collection).updateData([K.FStore.comment: FieldValue.delete(),
                                                                           K.FStore.date: FieldValue.delete()]) { error in completion(error) }
        }
    }
    
    func deleteGrade(collection: String?, document: String?, completion: @escaping (Error?) -> Void) {
        guard let document = document, let collection = collection else { completion(nil); return }
        db.collection(collection).document(document).updateData([K.FStore.grade: FieldValue.delete(),
                                                                 K.FStore.comment: FieldValue.delete(),
                                                                 K.FStore.date: FieldValue.delete()]) { [weak self] error in
            
            guard error == nil else { completion(error); return }
            
            self?.db.collection(document).document(collection).updateData([K.FStore.grade: FieldValue.delete(),
                                                                           K.FStore.comment: FieldValue.delete(),
                                                                           K.FStore.date: FieldValue.delete()]) { error in completion(error) }
        }
    }
    
    private func getFormattedDate() -> String {
        let date = Date()
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateformat.string(from: date)
    }
}
