//
//  FirebaseViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/07.
//

import Firebase

class FirebaseViewModel {
    
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
    
    func updateWishToWatch(DOCID: String,
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
                                                                                       K.FStore.date: date]) { error in
                completion(error)
            }
            
        } else {
            db.collection(userId).document("\(K.FStore.wishToWatch)\(DOCID)").delete() { error in
                completion(error)
            }
        }
    }
    
    func loadWishToWatch(DOCID: String, completion: @escaping (Bool) -> Void) {
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
    
    func loadUserInfose(DOCID: String, completion: @escaping ([UserInfoModel], Float, Error?) -> Void) {
        
        db.collection(DOCID).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else { completion([], 0.0, error); return }
            
            var userInfose: [UserInfoModel] = []
            var gradeTotal: Float = 0.0
            var gradeAverage: Float = 0.0
            
            if let snapshotDocuments = querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let userId = data[K.FStore.userId] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let grade = data[K.FStore.grade] as? Float,
                       let comment = data[K.FStore.comment] as? String,
                       let date = data[K.FStore.date] as? String {
                        
                        let newUserInfo = UserInfoModel(userId: userId,
                                                        movieName: movieName,
                                                        grade: grade,
                                                        comment: comment,
                                                        date: date)
                        userInfose.append(newUserInfo)
                    }
                }
                
                // 평균 평점
                if userInfose.count == 0 {
                    gradeAverage = 0
                } else {
                    for userInfo in userInfose {
                        gradeTotal += userInfo.grade
                    }
                    gradeAverage = gradeTotal / Float(userInfose.count)
                }
                
                completion(userInfose, gradeAverage, nil)
            }
        }
    }
    
    func loadCurrentUserInfo(DOCID: String, completion: @escaping (UserInfoModel?) -> Void) {
        
        guard let userId = self.userId else { completion(nil); return }
        
        db.collection(DOCID).document(userId).addSnapshotListener { documentSnapshot, error in
            
            guard error == nil, let document = documentSnapshot, let data = document.data() else { completion(nil); return }
            
            if let userId = data[K.FStore.userId] as? String,
               let movieName = data[K.FStore.movieName] as? String,
               let grade = data[K.FStore.grade] as? Float,
               let comment = data[K.FStore.comment] as? String,
               let date = data[K.FStore.date] as? String {
                
                let UserInfo = UserInfoModel(userId: userId,
                                             movieName: movieName,
                                             grade: grade,
                                             comment: comment,
                                             date: date)
                completion(UserInfo)
            }
        }
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
