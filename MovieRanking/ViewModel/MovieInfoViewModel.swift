//
//  MovieInfoViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/05.
//

import Foundation

class MovieInfoViewModel {
    var onUpdated: () -> Void = {}
    
    private let service = Service()

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
    
    func clearMovieInfoList() {
        movieInfoList = nil
    }
    
    // 영화별 정보 상세 - 한국영화데이터베이스
    func fetchMovieInfo(title movieName: String, completion: @escaping (Error?) -> Void) {
        movieInfoList = nil
        
        service.fetchMovieInfo(title: movieName) { [weak self] movieInfoList, error in
            guard movieInfoList.movieInfoModel(0).DOCID != "",
                  error == nil else { completion(error); return }
            
            self?.movieInfoList = movieInfoList
            completion(nil)
        }
    }
    
    func fetchMovieInfo(Id movieId: String, Seq movieSeq: String, completion: @escaping(Error?) -> Void) {
        movieInfoModel = nil
        
        service.fetchMovieInfo(Id: movieId, Seq: movieSeq) { [weak self] movieInfoList, error in
            guard movieInfoList.movieInfoModel(0).DOCID != "",
                  error == nil else { completion(error); return }
            
            self?.movieInfoModel = movieInfoList.movieInfoModel(0)
            completion(nil)
        }
    }
}
