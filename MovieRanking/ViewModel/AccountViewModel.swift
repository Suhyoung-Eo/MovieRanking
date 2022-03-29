//
//  AccountViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/17.
//

import Foundation

protocol AccountViewModelDelegate: AnyObject {
    func didUpdate()
    func didFailWithError(error: Error)
}

protocol StorageViewModelDelegate: AnyObject {
    func didUpdate()
    func didUpdateMovieInfo()
    func didFailWithError(error: Error)
}

class AccountViewModel {
    
    weak var delegate: AccountViewModelDelegate?
    
    private let movieInfoService = MovieInformationService()
    
    var userId: String? {
        return FirebaseService.shared.userId
    }
    
    var displayName: String? {
        return FirebaseService.shared.displayName
    }
    
    var isMovieInfoModelEmpty: Bool {
        return movieInfoModel.DOCID.isEmpty
    }
    
    var accountCommentListCount: Int {
        return accountCommentListModel == nil ? 0 : accountCommentListModel.count
    }
    
    func register(email: String, password: String) {
        FirebaseService.shared.register(email: email, password: password) { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.delegate?.didUpdate()
            }
        }
    }
    
    func logIn(email: String, password: String) {
        FirebaseService.shared.logIn(email: email, password: password) { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.delegate?.didUpdate()
            }
        }
    }
    
    func createProfileChangeRequest(displayName: String) {
        FirebaseService.shared.createProfileChangeRequest(displayName: displayName) { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.delegate?.didUpdate()
            }
        }
    }
    
    func logOut() {
        FirebaseService.shared.logOut { [weak self] error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.delegate?.didUpdate()
            }
        }
    }
    
    //MARK: - For StorageViewController
    
    weak var storageVMDelegate: StorageViewModelDelegate?
    
    var gradeListModel: GradeListModel!
    var movieInfoModel: MovieInfoModel!
    var gradeAverageList: [String] = []
    
    var wishToWatchListModel: WishToWatchListModel! {
        didSet {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.gradeAverageList = self.loadGradeAverage(by: self.wishToWatchListModel)
                self.storageVMDelegate?.didUpdate()
            }
        }
    }
    
    var gradeListCount: Int {
        return gradeListModel == nil ? 0 : gradeListModel.count
    }
    
    var wishToWatchListCount: Int {
        return wishToWatchListModel == nil ? 0 : wishToWatchListModel.count
    }
    
    func isExistItems(by title: String) -> Bool {
        switch title {
        case K.Prepare.wishToWatchListView:
            return wishToWatchListCount == 0 ? false : true
        case K.Prepare.gradeListView:
            return gradeListCount == 0 ? false : true
        default:
            return false
        }
    }
    
    func storageNumberOfItems(by title: String) -> Int {
        switch title {
        case K.Prepare.wishToWatchListView:
            return wishToWatchListCount
        case K.Prepare.gradeListView:
            return gradeListCount
        default:
            return 0
        }
    }
    
    func loadWishToWatchList() {
        FirebaseService.shared.loadWishToWatchList { [weak self] wishToWatchListModel, error in
            if let error = error {
                self?.storageVMDelegate?.didFailWithError(error: error)
            } else {
                self?.wishToWatchListModel = wishToWatchListModel
            }
        }
    }
    
    private func loadGradeAverage(by wishToWatchListModel: WishToWatchListModel) -> [String] {
        var averageList = [String]()
        let models = wishToWatchListModel.wishToWatchList
        let group = DispatchGroup()
        for model in models {
            group.enter()
            let DOCID: String = "\(model.movieId)\(model.movieSeq)"
            FirebaseService.shared.loadGradeAverageforAccount(DOCID: DOCID) { gradeAverage in
                averageList.append(gradeAverage == 0 ? "평점이 없습니다" : "평균 ★ \(String(format: "%.1f", gradeAverage))")
                group.leave()
            }
            group.wait()
        }
        return averageList
    }
    
    func loadGradeList() {
        FirebaseService.shared.loadGradeList { [weak self] gradeListModel, error in
            if let error = error {
                self?.storageVMDelegate?.didFailWithError(error: error)
            } else {
                self?.gradeListModel = gradeListModel
                self?.storageVMDelegate?.didUpdate()
            }
        }
    }
    
    //MARK: - For CommentsViewController
    
    var prepareId: String = ""
    var comment: String = ""
    var accountCommentListModel: AccountCommentListModel!
    
    func loadAccountCommentList() {
        FirebaseService.shared.loadAccountCommentList { [weak self] accountCommentListModel, error in
            if let error = error {
                self?.storageVMDelegate?.didFailWithError(error: error)
            } else {
                self?.accountCommentListModel = accountCommentListModel
                self?.storageVMDelegate?.didUpdate()
            }
        }
    }
    
    func deleteComment(userId: String?, index: Int) {
        let movieInfo = accountCommentListModel.accountCommentModel(index)
        FirebaseService.shared.deleteComment(collection: userId, document: movieInfo.DOCID) { [weak self] error in
            if let error = error {
                self?.storageVMDelegate?.didFailWithError(error: error)
            }
        }
    }
    
    //MARK: - 공통함수: StorageViewController / CommentsViewController
    
    func fetchMovieInfo(by itemTitle: String, index: Int) {
        var movieId: String = ""
        var movieSeq: String = ""
        
        switch itemTitle {
        case K.Prepare.wishToWatchListView:
            let movieInfo = wishToWatchListModel.wishToWatchModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        case K.Prepare.gradeListView:
            let movieInfo = gradeListModel.gradeModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
        case K.Prepare.addCommentView:
            let movieInfo = accountCommentListModel.accountCommentModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
            comment = movieInfo.comment
            prepareId = K.Prepare.addCommentView
        case K.Prepare.movieInfoView:
            let movieInfo = accountCommentListModel.accountCommentModel(index)
            movieId = movieInfo.movieId
            movieSeq = movieInfo.movieSeq
            prepareId = K.Prepare.movieInfoView
        default:
            break
        }
        
        movieInfoService.fetchMovieInfo(id: movieId, seq: movieSeq) { [weak self] movieInfoList, error in
            if let error = error {
                self?.delegate?.didFailWithError(error: error)
            } else {
                self?.movieInfoModel = movieInfoList.movieInfoModel(0)
                self?.storageVMDelegate?.didUpdateMovieInfo()
            }
        }
    }
}
