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
        
        apiService.fetchDailyBoxOffice(with: url) { [weak self] boxOfficeList, error in
            guard error == nil else { completion(BoxOfficeListModel([BoxOffice.empty]), MovieInfoListModel([MovieInfo.empty]), error); return }
            
            self?.loadMovieInfo(BoxOfficeListModel(boxOfficeList)) { results in
                completion(BoxOfficeListModel(boxOfficeList), results, nil)
            }
        }
    }
    
    // 주간/주말 박스오피스 리스트 - 영화진흥위원회
    func fetchWeeklyBoxOffice(by boxOfficeType: Int, completion: @escaping (BoxOfficeListModel, MovieInfoListModel, Error?) -> Void) {
        guard let boxOfficeDay = getBoxofficeDate(day: -7),
              let url = URL.urlForBoxOfficeApi(weekGb: boxOfficeType, targetDt: boxOfficeDay) else { return }
        
        apiService.fetchWeeklyBoxOffice(with: url) { [weak self] boxOfficeList, error in
            guard error == nil else { completion(BoxOfficeListModel([BoxOffice.empty]), MovieInfoListModel([MovieInfo.empty]), error); return }
            
            self?.loadMovieInfo(BoxOfficeListModel(boxOfficeList)) { results in
                completion(BoxOfficeListModel(boxOfficeList), results, nil)
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
        for i in 0..<boxOfficeList.count {
            group.enter()
            fetchMovieInfo(movieName: boxOfficeList[i].movieName, releaseDate: boxOfficeList[i].openDate) { movieInfoListModel in
                results.append(movieInfoListModel.movieInfoList[0].movieInfo)
                group.leave()
            }
            group.wait()
        }
        return results
    }

    // 영화별 정보 상세 - 한국영화데이터베이스
    private func fetchMovieInfo(movieName: String, releaseDate: String,  completion: @escaping(MovieInfoListModel) -> Void) {
        let releaseDts = releaseDate.replacingOccurrences(of: "-", with: "")
        guard let movieName = movieName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL.urlForMovieInfoApi(movieName: movieName, releaseDts: releaseDts) else { return }
        
        apiService.fetchMovieInfo(with: url) { movieInfo, error in
            guard error == nil else { completion(MovieInfoListModel([MovieInfo.empty])); return }
            completion(MovieInfoListModel(movieInfo))
        }
    }
    
    //MARK: - for searchMovieViewModel
    
    func fetchMovieInfo(title movieName: String, completion: @escaping(MovieInfoListModel, Error?) -> Void) {
        guard let movieName = movieName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL.urlForMovieInfoApi(movieName: movieName) else { return }
        
        apiService.fetchMovieInfo(with: url) { movieInfo, error in
            guard error == nil else { completion(MovieInfoListModel([MovieInfo.empty]), error); return }
            completion(MovieInfoListModel(movieInfo), nil)
        }
    }
    
    //MARK: - for StorageViewController
    
    func fetchMovieInfo(id movieId: String, seq movieSeq: String, completion: @escaping(MovieInfoListModel, Error?) -> Void) {
        guard let url = URL.urlForMovieInfoApi(movieId: movieId, movieSeq: movieSeq) else { return }
        print(url)
        apiService.fetchMovieInfo(with: url) { movieInfo, error in
            guard error == nil else { completion(MovieInfoListModel([MovieInfo.empty]), error); return }
            completion(MovieInfoListModel(movieInfo), nil)
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
