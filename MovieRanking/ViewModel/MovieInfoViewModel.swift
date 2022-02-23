//
//  MovieInfoViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/05.
//

import Foundation

class MovieInfoViewModel {
    
    var gotErrorStatus: () -> Void = {}
    var onUpdatedMovieInfoList: () -> Void = {}
    
    private let service = MovieInformationService()
    private let FBService = FirebaseService()
    
    var error: Error? {
        didSet {
            gotErrorStatus()
        }
    }
    
    //MARK: - MovieInformationService
    
    var movieInfoList: MovieInfoListModel! {
        didSet {
            onUpdatedMovieInfoList()
        }
    }
    
    var isMovieInfoModelEmpty: Bool {
        return movieInfoList.movieInfoModel(0).DOCID.isEmpty
    }
    
    var numberOfSections: Int {
        return movieInfoList == nil ? 0 : 1
    }
    
    var numberOfRowsInSection: Int {
        return (movieInfoList == nil || isMovieInfoModelEmpty) ? 0 : movieInfoList.count
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
        movieInfoList = nil
        service.fetchMovieInfo(title: movieName) { [weak self] movieInfoList, error in
            if let error = error {
                self?.error = error
            } else {
                self?.movieInfoList = movieInfoList
            }
        }
    }
    
    //MARK: - FirebaseService
    
    var onUpdatedGradeAverage: () -> Void = {}
    var onUpdateIsWishToWatch: () -> Void = {}
    var onUpdateCommentList: () -> Void = {}
    var onUpadteUserComment: () -> Void = {}
    
    /* For MovieInfoViewController */
    
    var gradeAverage: Float = 0.0 {
        didSet {
            onUpdatedGradeAverage()
        }
    }
    
    var isWishToWatch: Bool = false {
        didSet {
            onUpdateIsWishToWatch()
        }
    }
    
    var commentListModel: CommentListModel! {
        didSet {
            onUpdateCommentList()
        }
    }
    
    var gradeAndComment: (Float, String) = (0.0, "") {
        didSet {
            onUpadteUserComment()
        }
    }
    
    var userId: String? {
        return FBService.userId
    }
    
    var IsCommentExist: Bool {
        return (commentListModel == nil || commentListModel.count == 0) ? false : true
    }
    
    var gradeAverageText: String {
        return gradeAverage == 0 ? "첫 평점을 등록해 주세요" : "평균 ★ \(String(format: "%.1f", gradeAverage))"
    }
    
    func sectionCount(by section: Int) -> Int {
        switch section {
        case 6:
            return (commentListModel == nil || commentListModel.count == 0) ? 1 : commentListModel.count
        default:
            return 1
        }
    }
    
    func loadGradeAverage(DOCID: String) {
        FBService.loadGradeAverage(DOCID: DOCID) { [weak self] gradeAverage, error in
            if let error = error {
                self?.error = error
            } else {
                self?.gradeAverage = gradeAverage
            }
        }
    }
    
    func loadIsWishToWatch(DOCID: String) {
        FBService.loadIsWishToWatch(DOCID: DOCID) { [weak self] isWishToWatch, error in
            if let error = error {
                self?.error = error
            } else {
                self?.isWishToWatch = isWishToWatch
            }
        }
    }
    
    func loadCommentList(DOCID: String) {
        FBService.loadCommentList(DOCID: DOCID) { [weak self] commentListModel, error in
            if let error = error {
                self?.error = error
            } else {
                self?.commentListModel = commentListModel
            }
        }
    }
    
    func loadUserComment(DOCID: String) {
        FBService.loadUserComment(DOCID: DOCID) { [weak self] grade, comment, error in
            if let error = error {
                self?.error = error
            } else {
                self?.gradeAndComment = (grade, comment)
            }
        }
    }
    
    // 소비자 계정을 위한 초기 데이터 설정
    func setDataForAccount(movieInfo: MovieInfoModel) {
        FBService.setDataForAccount(movieInfo: movieInfo) { [weak self] error in
            if let error = error{
                self?.error = error
            }
        }
    }
    
    func setIsWishToWatch(DOCID: String, isWishToWatch: Bool) {
        FBService.setIsWishToWatch(DOCID: DOCID, isWishToWatch: isWishToWatch) { [weak self] error in
            if let error = error {
                self?.error = error
            } else {
                self?.isWishToWatch = isWishToWatch
            }
        }
    }
    
    func updateGrade(DOCID: String, grade: Float) {
        FBService.updateGrade(DOCID: DOCID, grade: grade) { [weak self] error in
            if let error = error {
                self?.error = error
            } else {
                self?.gradeAndComment = (grade, self?.gradeAndComment.1 ?? "")
                self?.loadGradeAverage(DOCID: DOCID)    // 평점 바낄때마다 평균 평점 갱신
            }
        }
    }
    
    func deleteGrade(DOCID: String) {
        FBService.deleteGrade(collection: DOCID, document: userId) { [weak self] error in
            if let error = error {
                self?.error = error
            } else {
                self?.gradeAndComment = (0.0, self?.gradeAndComment.1 ?? "")
                self?.loadGradeAverage(DOCID: DOCID)    // 평점 바낄때마다 평균 평점 갱신
            }
        }
    }
    
    /* For AddCommentViewController */
    
    var onUpdatedComment: () -> Void = {}
    
    var comment: String = "" {
        didSet {
            onUpdatedComment()
        }
    }
    
    func addComment(DOCID: String, comment: String) {
        FBService.addComment(DOCID: DOCID, comment: comment) { [weak self] error in
            if let error = error {
                self?.error = error
            } else {
                self?.comment = comment
            }
        }
    }
}
