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
    
    var movieInfoModelEmpty: Bool {
        return movieInfoList.movieInfoModel(0).DOCID.isEmpty
    }
    
    var numberOfSections: Int {
        return movieInfoList == nil ? 0 : 1
    }
    
    var numberOfRowsInSection: Int {
        return (movieInfoList == nil || movieInfoModelEmpty) ? 0 : movieInfoList.count
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
        error = nil
        movieInfoList = nil
    }
    
    // 영화별 정보 상세 - 한국영화데이터베이스
    func fetchMovieInfo(title movieName: String) {
        error = nil
        movieInfoList = nil
        service.fetchMovieInfo(title: movieName) { [weak self] movieInfoList, error in
            self?.error = error
            self?.movieInfoList = movieInfoList
        }
    }
    
    //MARK: - FirebaseService
    
    var onUpdatedFirebase: () -> Void = {}
    
    private var gradeAverage: Float = 0.0
    var commentListModel: CommentListModel!
    var isWishToWatch: Bool = false
    var grade: Float = 0.0
    var comment: String = ""
    var error: Error?
    
    /* For MovieInfoViewController */
    
    private var isUpdate: Bool = false {
        didSet {
            onUpdatedFirebase()
        }
    }
    
    var userId: String? {
        return FBService.userId
    }
    
    var IsCommentExist: Bool {
        return (commentListModel == nil || commentListModel.count == 0) ? false : true
    }
    
    func sectionCount(by section: Int) -> Int {
        switch section {
        case 6:
            return (commentListModel == nil || commentListModel.count == 0) ? 1 : commentListModel.count
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
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.gradeAverage = gradeAverage
            }
            self.isUpdate = !self.isUpdate
        }
    }
    
    func loadIsWishToWatch(DOCID: String) {
        error = nil
        FBService.loadIsWishToWatch(DOCID: DOCID) { [weak self] isWishToWatch, error in
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.isWishToWatch = isWishToWatch
            }
            self.isUpdate = !self.isUpdate
        }
    }
    
    func loadCommentList(DOCID: String) {
        error = nil
        commentListModel = nil
        FBService.loadCommentList(DOCID: DOCID) { [weak self] commentListModel, error in
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.commentListModel = commentListModel
            }
            self.isUpdate = !self.isUpdate
        }
    }
    
    func loadUserComment(DOCID: String) {
        error = nil
        FBService.loadUserComment(DOCID: DOCID) { [weak self] grade, comment, error in
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.grade = grade
                self.comment = comment
            }
            self.isUpdate = !self.isUpdate
        }
    }
    
    // 소비자 계정을 위한 초기 데이터 설정
    func setDataForAccount(movieInfo: MovieInfoModel) {
        error = nil
        FBService.setDataForAccount(movieInfo: movieInfo) { [weak self] error in
            if let error = error, let self = self {
                self.error = error
                self.isUpdate = !self.isUpdate
            }
        }
    }
    
    func setIsWishToWatch(DOCID: String, isWishToWatch: Bool) {
        error = nil
        FBService.setIsWishToWatch(DOCID: DOCID, isWishToWatch: isWishToWatch) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.isWishToWatch = isWishToWatch
            }
            self.isUpdate = !self.isUpdate
        }
    }
    
    func updateGrade(DOCID: String, grade: Float) {
        error = nil
        FBService.addComment(DOCID: DOCID, grade: grade, comment: comment) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.grade = grade
                self.loadGradeAverage(DOCID: DOCID)    // 평점 바낄때마다 평균 평점 갱신
            }
            self.isUpdate = !self.isUpdate
        }
    }
        
    func deleteGradeAndComment(DOCID: String) {
        error = nil
        FBService.deleteGradeAndComment(collection: DOCID, document: userId) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.grade = 0.0
                self.comment = ""
                self.loadGradeAverage(DOCID: DOCID)    // 평점 바낄때마다 평균 평점 갱신
            }
            self.isUpdate = !self.isUpdate
        }
    }
    
    /* For AddCommentViewController */
    
    var onUpdatedComment: () -> Void = {}
    
    var isUpdateComment: Bool = false {
        didSet {
            onUpdatedComment()
        }
    }
    
    func addComment(DOCID: String, grade: Float, comment: String) {
        error = nil
        FBService.addComment(DOCID: DOCID, grade: grade, comment: comment) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.comment = comment
            }
            self.isUpdateComment = !self.isUpdateComment
        }
    }
}
