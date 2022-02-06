//
//  MovieInfoModel.swift
//  MovingMovie
//
//  Created by Suhyoung Eo on 2021/12/08.
//

import Foundation

// 한국영화데이터베이스
struct MovieInformationModel: Codable {
    let Data: [Info]
}

struct Info: Codable {
    let Count: Int
    let Result: [MovieInfo]?
}

struct MovieInfo: Codable {
    let DOCID: String?
    let title: String?
    let titleEng: String?
    let titleOrg: String?
    let prodYear: String?
    let directors: Directors?
    let actors: Actors?
    let nation: String?
    let plots: Plots?
    let runtime: String?
    let rating: String?
    let genre: String?
    let posters: String?
    let stlls: String?
    let staffs: Staffs?
}

struct Directors: Codable {
    let director: [Director]?
}

struct Director: Codable {
    let directorNm: String?
    let directorEnNm: String?
}

struct Actors: Codable {
    let actor: [Actor]?
    
}

struct Actor: Codable {
    let actorNm: String?
    let actorEnNm: String?
}

struct Plots: Codable {
    let plot: [Plot]?
    
}

struct Plot: Codable {
    let plotText: String?
}

struct Staffs: Codable {
    let staff: [Staff]?
}

struct Staff: Codable {
    let staffNm: String?
    let staffEnNm: String?
    let staffRoleGroup: String?
}

extension MovieInformationModel {
    static var empty: Info {
        return Info(Count: 0,
                    Result: [])
    }
}

extension MovieInfo {
    static var empty: MovieInfo {
        return MovieInfo(DOCID: "",
                      title: "",
                      titleEng: "",
                      titleOrg: "",
                      prodYear: "",
                      directors: Directors(director: [Director.empty]),
                      actors: Actors(actor: [Actor.empty]),
                      nation: "",
                      plots: Plots(plot: [Plot.empty]),
                      runtime: "",
                      rating: "",
                      genre: "",
                      posters: "",
                      stlls: "",
                      staffs: Staffs(staff: [Staff.empty]))
    }
}

extension Director {
    static var empty: Director {
        return Director(directorNm: "", directorEnNm: "")
    }
}

extension Actor {
    static var empty: Actor {
        return Actor(actorNm: "", actorEnNm: "")
    }
}

extension Plot {
    static var empty: Plot {
        return Plot(plotText: "")
    }
}

extension Staff {
    static var empty: Staff {
        return Staff(staffNm: "", staffEnNm: "", staffRoleGroup: "")
    }
}
