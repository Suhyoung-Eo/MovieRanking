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
        return Auth.auth().currentUser?.uid
    }
    
    var displayName: String? {
        return Auth.auth().currentUser?.displayName
    }
    
    func register(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
    
    func createProfileChangeRequest(displayName: String, completion: @escaping (Error?) -> Void) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges { error in
            completion(error)
        }
    }
    
    func logIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            completion(error)
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
        
        db.collection(DOCID).getDocuments() { [weak self] documentSnapshot, error in
            guard error == nil else { completion(0.0, error); return }
            
            var gradeTotal: Float = 0.0
            var gradeCount: Float = 0.0
            var gradeAverage: Float = 0.0
            
            if let documents = documentSnapshot?.documents {
                
                for document in documents {
                    let data = document.data()
                    
                    if let grade = data[K.FStore.grade] as? Float, grade != 0 {
                        gradeTotal += grade
                        gradeCount += 1
                    }
                }
                
                // 평균 평점
                if gradeCount != 0 {
                    gradeAverage = gradeTotal / gradeCount
                }
                
                completion(gradeAverage, error)
                
                // 고객 서비스를 위해 따로 저장
                self?.updateGradeAverage(id: DOCID, average: gradeAverage)
            }
        }
    }
    
    func loadGradeAverageforAccount(DOCID: String, completion: @escaping (Float) -> Void) {
        db.collection(DOCID).document(K.FStore.gradeAverage).getDocument() { documentSnapshot, error in
            guard error == nil, let document = documentSnapshot else { completion(0); return }
            
            if let data = document.data(), let gradeAverage = data[K.FStore.gradeAverage] as? Float {
                completion(gradeAverage)
            } else {
                completion(0)
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
            
            guard error == nil else { completion(CommentListModel([CommentModel.empty]), error); return }
            
            var commentModelList: [CommentModel] = []
            
            if let documents = querySnapshot?.documents {
                
                for document in documents {
                    let data = document.data()
                    
                    if let displayName = data[K.FStore.displayName] as? String,
                       let grade = (data[K.FStore.grade] as? Float == nil ? 0 : data[K.FStore.grade] as? Float),
                       let comment = data[K.FStore.comment] as? String,
                       let date = data[K.FStore.date] as? String {
                        
                        let newItem = CommentModel(displayName: displayName,
                                                   grade: grade,
                                                   comment: comment,
                                                   date: date)
                        
                        if !comment.isEmpty {
                            commentModelList.append(newItem)
                        }
                    }
                }
                completion(CommentListModel(commentModelList), nil)
            }
        }
    }
    
    func loadWishToWatchList(completion: @escaping (WishToWatchListModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
        db.collection(userId).getDocuments() { documentSnapshot, error in
            
            guard error == nil else {
                completion(WishToWatchListModel([WishToWatchModel.empty]), error)
                return
            }
            
            var wishToWatchList: [WishToWatchModel] = []
            
            if let documents = documentSnapshot?.documents {
                
                for document in documents {
                    let data = document.data()
                    
                    if let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let isWishToWatch = data[K.FStore.wishToWatch] as? Bool,
                       isWishToWatch {
                        
                        let newItem = WishToWatchModel(movieId: movieId,
                                                       movieSeq: movieSeq,
                                                       movieName: movieName,
                                                       thumbNailLink: thumbNailLink,
                                                       isWishToWatch: isWishToWatch)
                        
                        wishToWatchList.append(newItem)
                    }
                }
                completion(WishToWatchListModel(wishToWatchList), nil)
            }
        }
    }
    
    func loadGradeList(completion: @escaping (GradeListModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
        db.collection(userId).getDocuments() { documentSnapshot, error in
            
            guard error == nil else {
                completion(GradeListModel([GradeModel.empty]), error)
                return
            }
            
            var gradeModelList: [GradeModel] = []
            
            if let documents = documentSnapshot?.documents {
                
                for document in documents {
                    let data = document.data()
                    
                    if let DOCID = data[K.FStore.DOCID] as? String,
                       let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let grade = data[K.FStore.grade] as? Float,
                       grade != 0 {
                        
                        let newItem = GradeModel(DOCID: DOCID,
                                                 movieId: movieId,
                                                 movieSeq: movieSeq,
                                                 movieName: movieName,
                                                 thumbNailLink: thumbNailLink,
                                                 grade: grade)
                        
                        gradeModelList.append(newItem)
                    }
                }
                completion(GradeListModel(gradeModelList), nil)
            }
        }
    }
    
    func loadAccountCommentList(completion: @escaping (AccountCommentListModel?, Error?) -> Void) {
        
        guard let userId = userId else { completion(nil, nil); return }
        
        db.collection(userId).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else {
                completion(AccountCommentListModel([AccountCommentModel.empty]), error)
                return
            }
            
            var accountCommentList: [AccountCommentModel] = []
            
            if let documents = querySnapshot?.documents {
                
                for document in documents {
                    let data = document.data()
                    
                    if let DOCID = data[K.FStore.DOCID] as? String,
                       let movieId = data[K.FStore.movieId] as? String,
                       let movieSeq = data[K.FStore.movieSeq] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let thumbNailLink = data[K.FStore.thumbNailLink] as? String,
                       let grade = (data[K.FStore.grade] as? Float == nil ? 0 : data[K.FStore.grade] as? Float),
                       let comment = data[K.FStore.comment] as? String,
                       let date = data[K.FStore.date] as? String,
                       !comment.isEmpty {
                        
                        let newItem = AccountCommentModel(DOCID: DOCID,
                                                          movieId: movieId,
                                                          movieSeq: movieSeq,
                                                          movieName: movieName,
                                                          thumbNailLink: thumbNailLink,
                                                          grade: grade,
                                                          comment: comment,
                                                          date: date)
                        
                        accountCommentList.append(newItem)
                    }
                }
                
                accountCommentList.sort { $0.date > $1.date }
                completion(AccountCommentListModel(accountCommentList), nil)
            }
        }
    }
    
    //MARK: - Create/ Update data methods
    
    func addComment(DOCID: String, comment: String, completion: @escaping (Error?) -> Void) {
        
        guard let userId = self.userId, let displayName = self.displayName else { completion(nil); return }
        let date = getFormattedDate()
        
        db.collection(DOCID).document(userId).setData([K.FStore.displayName : displayName,
                                                       K.FStore.comment: comment,
                                                       K.FStore.date: date]
                                                      , merge: true) { [weak self] error in
            
            guard error == nil else { completion(error); return }
            completion(error)
            self?.addCommentForAccount(userId, DOCID, comment, date)
        }
    }
    
    private func addCommentForAccount(_ userId: String, _ DOCID: String, _ comment: String, _ date: String) {
        db.collection(userId).document(DOCID).setData([K.FStore.comment: comment, K.FStore.date: date], merge: true)
    }
    
    func updateGrade(DOCID: String, grade: Float, completion: @escaping (Error?) -> Void) {
        guard let userId = self.userId, let displayName = self.displayName else { completion(nil); return }
        
        db.collection(DOCID).document(userId).setData([K.FStore.displayName : displayName,
                                                       K.FStore.grade : grade]
                                                      , merge: true) { [weak self] error in
            
            guard error == nil else { completion(error); return }
            completion(error)
            self?.updateGradeForAccount(userId, DOCID, grade)
        }
    }
    
    private func updateGradeForAccount(_ userId: String, _ DOCID: String, _ grade: Float) {
        db.collection(userId).document(DOCID).setData([K.FStore.grade: grade], merge: true)
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
    
    private func updateGradeAverage(id DOCID: String, average gradeAverage: Float) {
        db.collection(DOCID).document(K.FStore.gradeAverage).setData([K.FStore.gradeAverage: gradeAverage], merge: true)
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
        
        db.collection(collection).document(document).updateData([K.FStore.grade: FieldValue.delete()]) { [weak self] error in
            
            guard error == nil else { completion(error); return }
            
            self?.db.collection(document).document(collection).updateData([K.FStore.grade: FieldValue.delete()]) { error in completion(error) }
        }
    }
    
    private func getFormattedDate() -> String {
        let date = Date()
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateformat.string(from: date)
    }
}
