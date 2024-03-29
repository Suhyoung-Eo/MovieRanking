//
//  MovieInfoListModel.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import Foundation

struct MovieInfoListModel {
    let movieInfoList: [MovieInfoModel]
    
    init (_ movieInfo: [MovieInfo]) {
        self.movieInfoList = movieInfo.compactMap({ movieInfo in
            return MovieInfoModel.init(movieInfo)
        })
    }
}

extension MovieInfoListModel {
    
    var count: Int {
        return movieInfoList.count
    }
    
    func movieInfoModel(_ index: Int) -> MovieInfoModel {
        return movieInfoList[index]
    }
}

struct MovieInfoModel {
    let movieInfo: MovieInfo
    
    init (_ movieInfo: MovieInfo ) {
        self.movieInfo = movieInfo
    }
    
    var DOCID: String {
        return movieInfo.DOCID ?? ""
    }
    
    var movieId: String {
        return movieInfo.movieId ?? ""
    }
    
    var movieSeq: String {
        return movieInfo.movieSeq ?? ""
    }
    
    var movieName: String {
        var movieName: String = ""
        if let title = movieInfo.title {
            movieName = title.replacingOccurrences(of: " !HS ", with: "")
            movieName = movieName.replacingOccurrences(of: " !HE ", with: "")
            movieName = movieName.trimmingCharacters(in: .whitespaces)
        }
        return movieName
    }
    
    var movieNameOrg: String {
        var movieNameOrg: String = ""
        // 원제가 없는 경우 영문명으로 대체한다.
        if let titleOrg = movieInfo.titleOrg, !titleOrg.isEmpty {
            movieNameOrg = titleOrg.replacingOccurrences(of: "(", with: "")
        }
        else if let titleEng = movieInfo.titleEng {
            movieNameOrg = titleEng.replacingOccurrences(of: "  ", with: "")
            movieNameOrg = movieNameOrg.replacingOccurrences(of: "(", with: "")
            movieNameOrg = movieNameOrg.replacingOccurrences(of: ")", with: "")
        }
        return movieNameOrg
    }
    
    var prodYear: String {
        return movieInfo.prodYear ?? ""
    }
    
    var directors: [Director] {
        return movieInfo.directors?.director ?? []
    }
    
    var actors: [Actor] {
        return movieInfo.actors?.actor ?? []
    }
    
    var nation: String {
        var nations: String = ""
        if let nation = movieInfo.nation {
            nations = nation.replacingOccurrences(of: ",", with: "/")
        }
        return nations
    }
    
    var story: [Plot] {
        return movieInfo.plots?.plot ?? []
    }
    
    var runtime: String {
        var runtime: String = ""
        if let time = movieInfo.runtime, !time.isEmpty {
            runtime = "\(time) 분"
        }
        return runtime
    }
    
    var rating: String {
        return movieInfo.rating ?? ""
    }
    
    var genre: String {
        var genres: String = ""
        if let genre = movieInfo.genre {
            genres = genre.replacingOccurrences(of: ",", with: "/")
        }
        return genres
    }
    
    var thumbNailLinks: [String] {
        var thumbNailLinks: [String] = []
        if let posters = movieInfo.posters {
            thumbNailLinks = posters.components(separatedBy: "|")
        }
        return thumbNailLinks
    }
    
    var stllsLinks: [String] {
        var stllLinks: [String] = []
        if let stlls = movieInfo.stlls {
            stllLinks = stlls.components(separatedBy: "|")
        }
        return stllLinks
    }
    
    var staffs: [Staff] {
        return movieInfo.staffs?.staff ?? []
    }
}
