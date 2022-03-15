//
//  BoxOfficeViewModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import Foundation

protocol BoxOfficeViewModelDelegate: AnyObject {
    func didUpdate()
    func didFailWithError(error: Error)
}

class BoxOfficeViewModel {
    
    private let service = MovieInformationService()
    private let FBService = FirebaseService()
    
    weak var delegate: BoxOfficeViewModelDelegate?
    
    var boxOfficeList: BoxOfficeListModel!  // 박스 오피스 순위 정보를 가지고 있음
    var movieInfoList: MovieInfoListModel!  // 썸네일등 각 영화의 상세 정보를 가지고 있음
    var buttonTitle: String = ""
    
    // 앱 실행 시 회원가입을 했지만 닉네임을 저장하지 않은 경우 판별
    var isEmptyDisplayName: Bool {
        if FBService.userId == nil {
            return false
        } else {
            if FBService.displayName == nil {
                return true
            } else {
                return false
            }
        }
    }
    
    var numberOfSections: Int {
        return boxOfficeList == nil ? 0 : 1
    }
    
    var numberOfRowsInSection: Int {
        return boxOfficeList == nil ? 0 : boxOfficeList.count
    }
    
    func boxOfficeInfo(index: Int) -> (thumbNailLink: String, boxOfficeModel: BoxOfficeModel) {
        return (movieInfoList.movieInfoModel(index).thumbNailLinks[0], boxOfficeList.boxOfficeModel(index))
    }
    
    func fetchBoxOffice(by boxOfficeType: Int) {
        switch boxOfficeType {
        case 0: // 주간 (월~일)
            buttonTitle = "     ▼  주간 박스오피스"
            fetchWeeklyBoxOffice(by: 0)
        case 1: // 주말 (금~일)
            buttonTitle = "     ▼  주말 박스오피스"
            fetchWeeklyBoxOffice(by: 1)
        case 2: // 일별 (검색일 하루 전)
            buttonTitle = "     ▼  일별 박스오피스"
            fetchDailyBoxOffice()
        default:
            buttonTitle = "     ▼  주간 박스오피스"
            fetchWeeklyBoxOffice(by: 0)
        }
    }
    
    private func fetchWeeklyBoxOffice(by boxOfficeType: Int) {

        boxOfficeList = nil
        movieInfoList = nil
        delegate?.didUpdate()  // tableView Refresh
        
        service.fetchWeeklyBoxOffice(by: boxOfficeType) { [weak self] boxOfficeList, movieInfoList, error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.didFailWithError(error: error)
            } else {
                self.boxOfficeList = boxOfficeList
                self.movieInfoList = movieInfoList
                self.delegate?.didUpdate()
            }
        }
    }
    
    private func fetchDailyBoxOffice() {
        boxOfficeList = nil
        movieInfoList = nil
        delegate?.didUpdate()  // tableView Refresh
        
        service.fetchDailyBoxOffice { [weak self] boxOfficeList, movieInfoList, error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.didFailWithError(error: error)
            } else {
                self.boxOfficeList = boxOfficeList
                self.movieInfoList = movieInfoList
                self.delegate?.didUpdate()
            }
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
