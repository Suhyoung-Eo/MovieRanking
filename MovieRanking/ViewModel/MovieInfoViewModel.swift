//
//  MovieInfoViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/05.
//

import Foundation

protocol MovieInfoViewModelDelegate: AnyObject {
    func didUpdate()
    func didFailWithError(error: Error)
}

class MovieInfoViewModel {
    
    private let service = MovieInformationService()
    
    weak var delegate: MovieInfoViewModelDelegate?
    
    var movieInfoList: MovieInfoListModel!
    
    //MARK: - MovieInformationService
    
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
        movieInfoList = nil
        delegate?.didUpdate()
    }
    
    // 영화별 정보 상세 - 한국영화데이터베이스
    func fetchMovieInfo(title movieName: String) {
        movieInfoList = nil
        delegate?.didUpdate()  // tableView Refresh
        service.fetchMovieInfo(title: movieName) { [weak self] movieInfoList, error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.movieInfoList = movieInfoList
                self?.delegate?.didUpdate()
            }
        }
    }
    
    //MARK: - FirebaseService
    
    /* For MovieInfoViewController */
    
    var gradeAverage: Float = 0.0
    var isWishToWatch: Bool = false
    var commentListModel: CommentListModel!
    var gradeAndComment = (grade: Float(0.0), comment: "")
    
    var userId: String? {
        return FirebaseService.shared.userId
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
        FirebaseService.shared.loadGradeAverage(DOCID: DOCID) { [weak self] gradeAverage, error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.gradeAverage = gradeAverage
                self?.delegate?.didUpdate()
            }
        }
    }
    
    func loadIsWishToWatch(DOCID: String) {
        FirebaseService.shared.loadIsWishToWatch(DOCID: DOCID) { [weak self] isWishToWatch, error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.isWishToWatch = isWishToWatch
                self?.delegate?.didUpdate()
            }
        }
    }
    
    func loadCommentList(DOCID: String) {
        FirebaseService.shared.loadCommentList(DOCID: DOCID) { [weak self] commentListModel, error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.commentListModel = commentListModel
                self?.delegate?.didUpdate()
            }
        }
    }
    
    func loadUserComment(DOCID: String) {
        FirebaseService.shared.loadUserComment(DOCID: DOCID) { [weak self] grade, comment, error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.gradeAndComment = (grade, comment)
                self?.delegate?.didUpdate()
            }
        }
    }
    
    // 소비자 계정을 위한 초기 데이터 설정
    func setDataForAccount(movieInfo: MovieInfoModel) {
        FirebaseService.shared.setDataForAccount(movieInfo: movieInfo) { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            }
        }
    }
    
    func setIsWishToWatch(DOCID: String, isWishToWatch: Bool) {
        FirebaseService.shared.setIsWishToWatch(DOCID: DOCID, isWishToWatch: isWishToWatch) { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.isWishToWatch = isWishToWatch
                self?.delegate?.didUpdate()
            }
        }
    }
    
    func updateGrade(DOCID: String, grade: Float) {
        FirebaseService.shared.updateGrade(DOCID: DOCID, grade: grade) { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.gradeAndComment = (grade, self?.gradeAndComment.1 ?? "")
                self?.loadGradeAverage(DOCID: DOCID)    // 평점 바낄때마다 평균 평점 갱신
                self?.delegate?.didUpdate()
            }
        }
    }
    
    func deleteGrade(DOCID: String) {
        FirebaseService.shared.deleteGrade(collection: DOCID, document: userId) { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.gradeAndComment = (0.0, self?.gradeAndComment.1 ?? "")
                self?.loadGradeAverage(DOCID: DOCID)    // 평점 바낄때마다 평균 평점 갱신
                self?.delegate?.didUpdate()
            }
        }
    }
    
    /* For AddCommentViewController */
    
    var comment: String = ""
    
    func addComment(DOCID: String, comment: String) {
        FirebaseService.shared.addComment(DOCID: DOCID, comment: comment) { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.comment = comment
                self?.delegate?.didUpdate()
            }
        }
    }
}
