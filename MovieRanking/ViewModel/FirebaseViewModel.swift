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
    
    func addComment(DOCID: String, movieName: String, grade: Float, comment: String, completion: @escaping (Error?) -> Void) {
        
        guard let userId = self.userId else { completion(nil); return }
        
        let date = getFormattedDate()
        let docRef = db.collection(DOCID).document(userId)
        
        docRef.getDocument { document, error in
            
            docRef.setData([K.FStore.userId : userId,
                            K.FStore.movieName: movieName,
                            K.FStore.grade : grade,
                            K.FStore.comment: comment,
                            K.FStore.date: date]) { error in
                
                guard error == nil else { completion(error); return }
                completion(nil)
            }
        }
    }
    
    func loadUserComment(DOCID: String, completion: @escaping (CommentModel?) -> Void) {
        
        guard let userId = self.userId else { completion(nil); return }
        
        let docRef = db.collection(DOCID).document(userId)
        
        docRef.getDocument { document, error in
            
            guard let document = document, document.exists,
                  let data = document.data() else { completion(nil); return }
            
            if let userId = data[K.FStore.userId] as? String,
               let movieName = data[K.FStore.movieName] as? String,
               let grade = data[K.FStore.grade] as? Float,
               let comment = data[K.FStore.comment] as? String,
               let date = data[K.FStore.date] as? String {
                
                let UserComment = CommentModel(userId: userId,
                                               movieName: movieName,
                                               grade: grade,
                                               comment: comment,
                                               date: date)
                completion(UserComment)
            }
        }
    }
    
    func loadComments(DOCID: String, completion: @escaping ([CommentModel], Float, Int, Error?) -> Void) {
        
        db.collection(DOCID).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            guard error == nil else { completion([], 0.0, 0, error); return }
            
            var comments: [CommentModel] = []
            var gradeTotal: Float = 0.0
            
            if let snapshotDocuments = querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    
                    if let userId = data[K.FStore.userId] as? String,
                       let movieName = data[K.FStore.movieName] as? String,
                       let grade = data[K.FStore.grade] as? Float,
                       let comment = data[K.FStore.comment] as? String,
                       let date = data[K.FStore.date] as? String {
                        
                        let newComment = CommentModel(userId: userId,
                                                      movieName: movieName,
                                                      grade: grade,
                                                      comment: comment,
                                                      date: date)
                        comments.append(newComment)
                    }
                }
                
                // 평균 평점을 계산하기 위해 필요
                for comment in comments {
                    gradeTotal += comment.grade
                }
                
                completion(comments, gradeTotal, comments.count, nil)
            }
        }
    }
    
    private func getFormattedDate() -> String {
        let date = Date()
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateformat.string(from: date)
    }
}
