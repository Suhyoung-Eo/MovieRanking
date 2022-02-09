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
    
    func logOut(completion: @escaping (String?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error as NSError {
            let error = "\(error)"
            completion(error)
        }
    }
    
    func addComment(DOCID: String, movieName: String, grade: Float, comment: String, completion: @escaping (Error?) -> Void) {

        if let userId = self.userId {
            let date = getFormattedDate()
            
            db.collection(DOCID).addDocument(data: [K.FStore.userId : userId,
                                                    K.FStore.movieName: movieName,
                                                    K.FStore.grade : grade,
                                                    K.FStore.comment: comment,
                                                    K.FStore.date: date]) { error in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func loadComments(DOCID: String, completion: @escaping ([CommentModel], String, Error?) -> Void) {
        
        db.collection(DOCID).order(by: K.FStore.date, descending: true).addSnapshotListener { querySnapshot, error in
            
            var comments: [CommentModel] = []
            var gradeTotal: Float = 0.0
            var gradeAverage: Float = 0.0
            var gradeAverageString = ""
            
            if let error = error {
                completion([], "", error)
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        
                        if let userId = data[K.FStore.userId] as? String,
                           let movieName = data[K.FStore.movieName] as? String,
                           let grade = data[K.FStore.grade] as? Float,
                           let comment = data[K.FStore.comment] as? String,
                           let date = data[K.FStore.date] as? String {
                            
                            let newCommet = CommentModel(userId: userId,
                                                         movieName: movieName,
                                                         grade: grade,
                                                         comment: comment,
                                                         date: date)
                            comments.append(newCommet)
                        }
                    }
                    
                    for comment in comments {
                        gradeTotal += comment.grade
                    }
                    
                    gradeAverage = gradeTotal / Float(comments.count)
                    
                    if comments.count == 0 {
                        gradeAverageString = "첫 평점을 등록해 주세요"
                        completion(comments, gradeAverageString, nil)
                    } else {
                        let average = String(format: "%.1f", gradeAverage)
                        gradeAverageString = "평균 ★ \(average)"
                        completion(comments, gradeAverageString, nil)
                    }
                }
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
