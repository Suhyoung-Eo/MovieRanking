//
//  Constant.swift
//  MovingMovie
//
//  Created by Suhyoung Eo on 2021/11/26.
//

struct K {
    
    // 오픈 Api 주소
    struct Api {
        
        /* 영화진흥위원회 */
        // 일별 박스오피스
        static let koficDailyBoxOfficeListURL = "http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key="
        // 주간/주말 박스오피스
        static let koficWeeklyBoxOfficeListURL = "http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchWeeklyBoxOfficeList.json?key="
        
        // 영화 검색
        static let koficMovieInfoURL = "http://www.kobis.or.kr/kobisopenapi/webservice/rest/movie/searchMovieInfo.json?key="
        
        // 한국영화데이터베이스
        static let kmdbURL = "http://api.koreafilm.or.kr/openapi-data2/wisenut/search_api/search_json2.jsp?collection=kmdb_new2&ServiceKey="
    }
    
    struct CellIdentifier {
        static let boxOfficeCell = "BoxOfficeCell"
        static let searchMovieCell = "SearchMovieCell"
        static let movieImageCell = "MovieImageCell"
        static let gradeAverageTableViewCell = "GradeAverageTableViewCell"
        static let movieDetailInfoCell = "MovieDetailInfoCell"
        static let directorAndActorsNameCell = "DirectorAndActorsNameCell"
        static let staffsInfoCell = "staffsInfoCell"
        static let addCommentButtonCell = "AddCommentButtonCell"
        static let commentCell = "CommentCell"
        static let imageCollectionViewCell = "ImageCollectionViewCell"
    }
    
    struct SegueIdentifier {
        static let resultView = "goToResultView"
        static let staffsInfoTableView = "goToStaffsInfoView"
        static let addCommentView = "goToAddCommentView"
        static let loginView = "goToLoginView"
        static let registerView = "goToRegisterView"
        static let imageView = "goToImageView"
        static let movieListOptionView = "goToMovieListOptionView"
    }
    
    struct StoryboardID {
        static let boxOfficeTypeOptionView = "BoxOfficeTypeOptionTableViewController"
    }
    
    struct Image {
        static let noImage = "no_image"
        static let starFull = "star_full"
        static let starHalf = "star_half"
        static let starEmpty = "star_empty"
        static let veryGoodFace = "very_good_face"
        static let goodFace = "good_face"
        static let normalFace = "normal_face"
        static let badFace = "bad_face"
        static let tooBadFace = "too_bad_face"
    }
    
    struct FStore {
        static let senderField = "sender"
        static let titleField = "title"
        static let gradeField = "grade"
        static let bodyField = "body"
        static let dateField = "date"
    }
    
}
