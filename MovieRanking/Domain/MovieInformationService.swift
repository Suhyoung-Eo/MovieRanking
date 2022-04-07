//
//  MovieInformaition.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import Foundation

class MovieInformationService {
    // 박스오피스 정보 취득 순서
    // 1. fetchDailyBoxOffice/ fetchWeeklyBoxOffice: 박스오피스 Top 10 영화리스트 정보 취득 - 영화진흥위원회
    // 2. fetchMovieInfo: 1번에서 취득한 movieNm과 openDt 조합으로 필요한 영화 정보 취득 - 한국영화데이터베이스
    
    private let apiService = ApiService()
    
    //MARK: - for BoxOfficeViewModel
    
    // 일일 박스오피스 리스트 - 영화진흥위원회
    func fetchDailyBoxOffice(completion: @escaping (BoxOfficeListModel, MovieInfoListModel, Error?) -> Void) {
        guard let boxOfficeDay = getBoxofficeDate(day: -1),
              let url = URL.urlForBoxOfficeApi(targetDt: boxOfficeDay) else { return }
        
        let resource = Resource<DailyBoxOfficeModel>(url: url)
        
        apiService.fetchData(resource: resource) { [weak self] result in
            switch result {
            case .success(let dailyBoxOffice):
                self?.loadMovieInfo(BoxOfficeListModel(dailyBoxOffice.boxOfficeResult.dailyBoxOfficeList)) { movieInfoList in
                    completion(BoxOfficeListModel(dailyBoxOffice.boxOfficeResult.dailyBoxOfficeList), movieInfoList, nil)
                }
            case .failure(let error):
                completion(BoxOfficeListModel([BoxOffice.empty]), MovieInfoListModel([MovieInfo.empty]), error)
            }
        }
    }
    
    // 주간/주말 박스오피스 리스트 - 영화진흥위원회
    func fetchWeeklyBoxOffice(by boxOfficeType: Int, completion: @escaping (BoxOfficeListModel, MovieInfoListModel, Error?) -> Void) {
        guard let boxOfficeDay = getBoxofficeDate(day: -7),
              let url = URL.urlForBoxOfficeApi(weekGb: boxOfficeType, targetDt: boxOfficeDay) else { return }
        
        let resource = Resource<WeeklyBoxOfficeModel>(url: url)
        
        apiService.fetchData(resource: resource) { [weak self] result in
            switch result {
            case .success(let weeklyBoxOffice):
                self?.loadMovieInfo(BoxOfficeListModel(weeklyBoxOffice.boxOfficeResult.weeklyBoxOfficeList)) { movieInfoList in
                    completion(BoxOfficeListModel(weeklyBoxOffice.boxOfficeResult.weeklyBoxOfficeList), movieInfoList, nil)
                }
            case .failure(let error):
                completion(BoxOfficeListModel([BoxOffice.empty]), MovieInfoListModel([MovieInfo.empty]), error)
            }
        }
    }
   
    private func loadMovieInfo(_ boxOfficeList: BoxOfficeListModel, completion: @escaping (MovieInfoListModel) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let movieInfo = self.fetchMovieInfo(by: boxOfficeList)
            
            DispatchQueue.main.async {
                completion(MovieInfoListModel(movieInfo))
            }
        }
    }
    
    // 박스오피스 순위대로 results 배열에 sequentially 저장
    private func fetchMovieInfo(by boxOfficeListModel: BoxOfficeListModel) -> [MovieInfo] {
        var results = [MovieInfo]()
        let boxOfficeList = boxOfficeListModel.boxOfficeList
        let group = DispatchGroup()
        boxOfficeList.forEach({ boxOfficeModel in
            group.enter()
            fetchMovieInfo(movieName: boxOfficeModel.movieName, releaseDate: boxOfficeModel.openDate) { movieInfoListModel in
                results.append(movieInfoListModel.movieInfoList[0].movieInfo)
                group.leave()
            }
            group.wait()
        })
        return results
    }

    // 영화별 정보 상세 - 한국영화데이터베이스
    private func fetchMovieInfo(movieName: String, releaseDate: String,  completion: @escaping(MovieInfoListModel) -> Void) {
        let releaseDts = releaseDate.replacingOccurrences(of: "-", with: "")
        guard let movieName = movieName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL.urlForMovieInfoApi(movieName: movieName, releaseDts: releaseDts) else { completion(MovieInfoListModel([MovieInfo.empty])); return }
        
        let resource = Resource<MovieInformationModel>(url: url)
        
        apiService.fetchData(resource: resource) { result in
            switch result {
            case .success(let movieInfoModel):
                completion(MovieInfoListModel(movieInfoModel.Data[0].Result ?? [MovieInfo.empty]))
            case .failure(_):
                completion(MovieInfoListModel([MovieInfo.empty]))
            }
        }
    }
    
    //MARK: - for searchMovieViewModel
    
    func fetchMovieInfo(title movieName: String, completion: @escaping(MovieInfoListModel, Error?) -> Void) {
        guard let movieName = movieName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL.urlForMovieInfoApi(movieName: movieName) else { completion(MovieInfoListModel([MovieInfo.empty]), nil); return }
        
        let resource = Resource<MovieInformationModel>(url: url)
        
        apiService.fetchData(resource: resource) { result in
            switch result {
            case .success(let movieInfoModel):
                completion(MovieInfoListModel(movieInfoModel.Data[0].Result ?? [MovieInfo.empty]), nil)
            case .failure(let error):
                completion(MovieInfoListModel([MovieInfo.empty]), error)
            }
        }
    }
    
    //MARK: - for StorageViewController
    
    func fetchMovieInfo(id movieId: String, seq movieSeq: String, completion: @escaping(MovieInfoListModel, Error?) -> Void) {
        guard let url = URL.urlForMovieInfoApi(movieId: movieId, movieSeq: movieSeq) else { completion(MovieInfoListModel([MovieInfo.empty]), nil); return }
        
        let resource = Resource<MovieInformationModel>(url: url)
        
        apiService.fetchData(resource: resource) { result in
            switch result {
            case .success(let movieInfoModel):
                completion(MovieInfoListModel(movieInfoModel.Data[0].Result ?? [MovieInfo.empty]), nil)
            case .failure(let error):
                completion(MovieInfoListModel([MovieInfo.empty]), error)
            }
        }
    }
    
    // 일일 박스오피스 기준일 - 검색 하루 전 value = -1
    // 주간/주말 박스오피스 기준일 - 검색 일주일 전 value = -7
    private func getBoxofficeDate(day: Int) -> String? {
        var Boxofficedate: String?
        let theDay = Calendar.current.date(byAdding: .day, value: day, to: Date())
        let boxOfficeDay = "\(String(describing: theDay!))".split(separator: "+").first
        
        // api 호출 가능한 string 포맷으로 변환
        let getDateFormatter = DateFormatter()
        getDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss "
        let outDateFormatter = DateFormatter()
        outDateFormatter.dateFormat = "yyyyMMdd"
        
        if let date = getDateFormatter.date(from: "\(String(describing: boxOfficeDay!))") {
            Boxofficedate = outDateFormatter.string(from: date)
        }
        return Boxofficedate
    }
}
