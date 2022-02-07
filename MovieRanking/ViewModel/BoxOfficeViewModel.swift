//
//  BoxOfficeViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import Foundation

class BoxOfficeViewModel {
    var onUpdated: () -> Void = {}
    
    private let service = Service()
    
    // 박스 오피스 순위 정보를 가지고 있음
    var boxOfficeList: BoxOfficeListModel!
    // 썸네일등 각 영화의 상세 정보를 가지고 있음
    var movieInfoList: MovieInfoListModel! {
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
    
    func fetchWeeklyBoxOffice(by boxOfficeType: Int, completion: @escaping (Error?) -> Void) {
        boxOfficeList = nil
        movieInfoList = nil
        
        service.fetchWeeklyBoxOffice(by: boxOfficeType) { [weak self] boxOfficeList, movieInfoList, error in
            guard error == nil else { completion(error); return }
            self?.boxOfficeList = boxOfficeList
            self?.movieInfoList = movieInfoList
            completion(nil)
        }
    }
    
    func fetchDailyBoxOffice(completion: @escaping (Error?) -> Void) {
        boxOfficeList = nil
        movieInfoList = nil
        
        service.fetchDailyBoxOffice { [weak self] boxOfficeList, movieInfoList, error in
            guard error == nil else { completion(error); return }
            self?.boxOfficeList = boxOfficeList
            self?.movieInfoList = movieInfoList
            completion(nil)
        }
    }
    
    //MARK: - OptionTableViewController business logic
    
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
