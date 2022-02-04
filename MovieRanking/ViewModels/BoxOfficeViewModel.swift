//
//  BoxOfficeViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import Foundation

class BoxOfficeViewModel {
    var onUpdated: () -> Void = {}
    
    private let service = APIService()
    
    // 화면에 보여줘야 되는 값
    var boxOfficeList = BoxOfficeListModel([BoxOffice.empty]) {
        didSet {
            print("boxOfficeList")
        }
    }
    var movieInfoList = MovieInfoListModel([MovieInfo.empty]) {
        didSet {
            onUpdated()
        }
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfRowsInSection: Int {
        return movieInfoList.count == 1 ? 0 : movieInfoList.count
    }
    
    func fetchWeeklyBoxOffice(by boxOfficeType: Int) {
        service.fetchWeeklyBoxOffice(by: boxOfficeType) { [weak self] boxOfficeList, movieInfoList, error in
            guard error == nil else { return }
            self?.boxOfficeList = boxOfficeList
            self?.movieInfoList = movieInfoList
        }
    }
    
    func fetchDailyBoxOffice() {
        service.fetchDailyBoxOffice { [weak self] boxOfficeList, movieInfoList, error in
            guard error == nil else { return }
            self?.boxOfficeList = boxOfficeList
            self?.movieInfoList = movieInfoList
        }
    }
}
