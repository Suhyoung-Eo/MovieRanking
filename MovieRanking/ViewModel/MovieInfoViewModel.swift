//
//  MovieInfoViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/05.
//

import Foundation

class MovieInfoViewModel {
    
    var onUpdated: () -> Void = {}
    
    private let service = MovieInformationService()
    private let FBService = FirebaseService()
    
    //MARK: - MovieInformationService
    
    var movieInfoModel: MovieInfoModel!
    
    var movieInfoList: MovieInfoListModel! {
        didSet {
            onUpdated()
        }
    }
    
    var numberOfSections: Int {
        return movieInfoList == nil ? 0 : 1
    }
    
    var numberOfRowsInSection: Int {
        return movieInfoList == nil ? 0 : movieInfoList.count
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
    
    func clearMovieInfoList() {
        movieInfoList = nil
    }
    
    // 영화별 정보 상세 - 한국영화데이터베이스
    func fetchMovieInfo(title movieName: String, completion: @escaping (Error?) -> Void) {
        movieInfoList = nil
        
        service.fetchMovieInfo(title: movieName) { [weak self] movieInfoList, error in
            guard error == nil, !movieInfoList.movieInfoModel(0).DOCID.isEmpty else { completion(error); return }
            
            self?.movieInfoList = movieInfoList
            completion(nil)
        }
    }
    
    //MARK: - FirebaseService
    
    var onUpdatedFirebase: () -> Void = {}
    
    var commentListModel: CommentListModel!
    // var DOCID: String = ""
    var comment: String = ""
    var grade: Float = 0.0
    
    /* For MovieInfoViewController */
    
    var error: Error? {
        didSet {
            guard error != nil else { return }
            onUpdatedFirebase()
        }
    }
    
    var isWishToWatch: Bool = false {
        didSet {
            guard error == nil else { return }
            onUpdatedFirebase()
        }
    }
    
    private var gradeAverage: Float = 0.0 {
        didSet {
            guard error == nil else { return }
            onUpdatedFirebase()
        }
    }
    
    var userId: String? {
        return FBService.userId
    }
    
    private var commentListCount: Int {
        return (commentListModel == nil || commentListModel.count == 0) ? 1 : commentListModel.count
    }
    
    var IsCommentExist: Bool {
        return (commentListModel == nil || commentListModel.count == 0) ? false : true
    }
    
    func sectionCount(by section: Int) -> Int {
        switch section {
        case 6:
            return commentListCount
        default:
            return 1
        }
    }
    
    var gradeAverageText: String {
        return gradeAverage == 0 ? "첫 평점을 등록해 주세요" : "평균 ★ \(String(format: "%.1f", gradeAverage))"
    }
    
    func loadGradeAverage(DOCID: String) {
        error = nil
        FBService.loadGradeAverage(DOCID: DOCID) { [weak self] gradeAverage, error in
            if let error = error {
                self?.error = error
            } else {
                self?.gradeAverage = gradeAverage
            }
        }
    }
    
    func loadIsWishToWatch(DOCID: String) {
        error = nil
        FBService.loadIsWishToWatch(DOCID: DOCID) { [weak self] isWishToWatch, error in
            if let error = error {
                self?.error = error
            } else {
                self?.isWishToWatch = isWishToWatch
            }
        }
    }
    
    func loadCommentList(DOCID: String) {
        error = nil
        commentListModel = nil
        FBService.loadCommentList(DOCID: DOCID) { [weak self] commentListModel, error in
            if let error = error {
                self?.error = error
            } else {
                self?.commentListModel = commentListModel
            }
        }
    }
    
    // 소비자 계정을 위한 초기 데이터 설정
    func setDataForAccount(movieInfo: MovieInfoModel) {
        error = nil
        FBService.setDataForAccount(movieInfo: movieInfo) { [weak self] error in
            self?.error = error
        }
    }
    
    /* For AddCommentViewController */
    
    func loadUserComment(DOCID: String, completion: @escaping (Error?) -> Void) {
        FBService.loadUserComment(DOCID: DOCID) { [weak self] grade, comment, error in
            guard error == nil else { completion(error); return }
            self?.grade = grade
            self?.comment = comment
            completion(nil)
        }
    }
    
    func addComment(DOCID: String, grade: Float, comment: String, completion: @escaping (Error?) -> Void) {
        FBService.addComment(DOCID: DOCID, grade: grade, comment: comment) { [weak self] error in
            guard error == nil else { completion(error); return }
            self?.grade = grade
            self?.comment = comment
            self?.loadGradeAverage(DOCID: DOCID)    // 평점 바낄때마다 평균 평점 갱신
            completion(nil)
        }
    }
    
    func setIsWishToWatch(DOCID: String, isWishToWatch: Bool) {
        error = nil
        FBService.setIsWishToWatch(DOCID: DOCID, isWishToWatch: isWishToWatch) { [weak self] error in
            if let error = error {
                self?.error = error
            } else {
                self?.isWishToWatch = isWishToWatch
            }
        }
    }
    
    func deleteGrade(DOCID: String, userId: String, completion: @escaping (Error?) -> Void) {
        FBService.deleteGrade(collection: DOCID, document: userId) { [weak self] error in
            guard error == nil else { completion(error); return }
            self?.grade = 0.0
            self?.comment = ""
            self?.loadGradeAverage(DOCID: DOCID)    // 평점 바낄때마다 평균 평점 갱신
            completion(nil)
        }
    }
}
