//
//  BoxOfficeViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import Foundation

class BoxOfficeViewModel {
    
    var onUpdated: () -> Void = {}
    
    private let service = MovieInformationService()
    
    var boxOfficeList: BoxOfficeListModel!  // 박스 오피스 순위 정보를 가지고 있음
    var movieInfoList: MovieInfoListModel!  // 썸네일등 각 영화의 상세 정보를 가지고 있음
    var buttontitle: String = ""
    var error: Error?
    
    private var isUpdate: Bool = false {
        didSet {
            onUpdated()
        }
    }
    
    var numberOfSections: Int {
        return boxOfficeList == nil ? 0 : 1
    }
    
    var numberOfRowsInSection: Int {
        return boxOfficeList == nil ? 0 : boxOfficeList.count
    }
    
    func boxOfficeInfo(index: Int) -> (String, BoxOfficeModel) {
        return (movieInfoList.movieInfoModel(index).thumbNailLinks[0], boxOfficeList.boxOfficeModel(index))
    }
    
    func fetBoxOffice(by boxOfficeType: Int) {
        error = nil
        
        switch boxOfficeType {
        case 0: // 주간 (월~일)
            buttontitle = "     ▼  주간 박스오피스"
            fetchWeeklyBoxOffice(by: 0)
        case 1: // 주말 (금~일)
            buttontitle = "     ▼  주말 박스오피스"
            fetchWeeklyBoxOffice(by: 1)
        case 2: // 일별 (검색일 하루 전)
            buttontitle = "     ▼  일별 박스오피스"
            fetchDailyBoxOffice()
        default:
            buttontitle = "     ▼  주간 박스오피스"
            fetchWeeklyBoxOffice(by: 0)
        }
    }
    
    private func fetchWeeklyBoxOffice(by boxOfficeType: Int) {
        error = nil
        boxOfficeList = nil
        movieInfoList = nil
        isUpdate = !isUpdate    // tableView Refresh
        
        service.fetchWeeklyBoxOffice(by: boxOfficeType) { [weak self] boxOfficeList, movieInfoList, error in
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.boxOfficeList = boxOfficeList
                self.movieInfoList = movieInfoList
            }
            self.isUpdate = !self.isUpdate
        }
    }
    
    private func fetchDailyBoxOffice() {
        error = nil
        boxOfficeList = nil
        movieInfoList = nil
        isUpdate = !isUpdate    // tableView Refresh
        
        service.fetchDailyBoxOffice { [weak self] boxOfficeList, movieInfoList, error in
            guard let self = self else { return }
            if let error = error {
                self.error = error
            } else {
                self.boxOfficeList = boxOfficeList
                self.movieInfoList = movieInfoList
            }
            self.isUpdate = !self.isUpdate
        }
    }
    
    /* For OptionTableViewController */
    
    var boxOfficeTypes = ["주간 박스오피스", "주말 박스오피스", "일별 박스오피스"]
    var checkBoxOfficeType = [false, false, false]
    
    func setBoxOfficeType(by index: Int) {
        checkBoxOfficeType[index] = true
        
        switch index {
        case 0:
            checkBoxOfficeType[1] = false
            checkBoxOfficeType[2] = false
        case 1:
            checkBoxOfficeType[0] = false
            checkBoxOfficeType[2] = false
        case 2:
            checkBoxOfficeType[0] = false
            checkBoxOfficeType[1] = false
        default:
            checkBoxOfficeType[1] = false
            checkBoxOfficeType[2] = false
        }
    }
}
