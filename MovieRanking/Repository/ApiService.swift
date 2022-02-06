//
//  APIService.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import Foundation

class ApiService {
        
    // 영화진흥위원회 일일 박스오피스 순위 검색
    func fetchDailyBoxOffice(with url: URL, completion: @escaping ([BoxOffice], Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, reponse, error in
            guard let data = data, error == nil else { completion([], error); return }
            do {
                let boxOfficeModel = try JSONDecoder().decode(DailyBoxOfficeModel.self, from: data)
                completion(boxOfficeModel.boxOfficeResult.dailyBoxOfficeList, nil)
            } catch {
                completion([], error)
            }
        }
        .resume()
    }
    
    // 영화진흥위원회 주간/주말 박스오피스 순위 검색
    func fetchWeeklyBoxOffice(with url: URL, completion: @escaping ([BoxOffice], Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, reponse, error in
            guard let data = data, error == nil else { completion([], error); return }
            do {
                let boxOfficeModel = try JSONDecoder().decode(WeeklyBoxOfficeModel.self, from: data)
                completion(boxOfficeModel.boxOfficeResult.weeklyBoxOfficeList, nil)
            } catch {
                completion([], error)
            }
        }
        .resume()
    }
    
    // 한국영화데이터베이스 영화 검색
    func fetchMovieInfo(with url: URL, completion: @escaping ([MovieInfo], Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { completion([MovieInfo.empty], error); return}
            do {
                let movieInfoModel = try JSONDecoder().decode(MovieInformationModel.self, from: data)
                completion(movieInfoModel.Data[0].Result ?? [MovieInfo.empty], nil)
            } catch {
                completion([MovieInfo.empty], error)
            }
        }
        .resume()
    }
}
