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
        // 일별/주간/주말 박스오피스, 영화 검색
        static let koficDailyBoxOfficeListURL = "http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key="
        static let koficWeeklyBoxOfficeListURL = "http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchWeeklyBoxOfficeList.json?key="
        static let koficMovieInfoURL = "http://www.kobis.or.kr/kobisopenapi/webservice/rest/movie/searchMovieInfo.json?key="
        
        /* 한국영화데이터베이스 */
        static let kmdbURL = "http://api.koreafilm.or.kr/openapi-data2/wisenut/search_api/search_json2.jsp?collection=kmdb_new2&ServiceKey="
    }
    
    struct CellId {
        static let boxOfficeCell = "BoxOfficeCell"
        static let searchMovieCell = "SearchMovieCell"
        static let movieImageCell = "MovieImageCell"
        static let imageCollectionViewCell = "ImageCollectionViewCell"
        static let detailInfoCell = "DetailInfoCell"
        static let staffsInfoCell = "StaffsInfoCell"
        static let userInteractionCell = "UserInteractionCell"
        static let commentHeadCell = "CommentHeadCell"
        static let commentCell = "CommentCell"
        static let ratingStarsCell = "RatingStarsCell"
        static let accountCell = "AccountCell"
        static let storageCell = "StorageCell"
        static let userCommentCell = "UserCommentCell"
    }
    
    struct SegueId {
        static let movieInfoView = "goToMovieInfoView"
        static let staffsInfoTableView = "goToStaffsInfoView"
        static let addCommentView = "goToAddCommentView"
        static let loginView = "goToLoginView"
        static let registerView = "goToRegisterView"
        static let imageView = "goToImageView"
        static let movieListOptionView = "goToMovieListOptionView"
        static let storageView = "goToStorageView"
        static let commentListView = "goToCommentListView"
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
        static let userId = "userId"
        static let DOCID = "DOCID"
        static let movieId = "movieId"
        static let movieSeq = "movieSeq"
        static let movieName = "movieName"
        static let thumbNailLink = "thumbNailLink"
        static let gradeAverage = "gradeAverage"
        static let isWishToWatch = "isWishToWatch"
        static let grade = "grade"
        static let comment = "comment"
        static let date = "date"
    }
    
    struct Prepare {
        static let movieInfoView = "movieInfoView"
        static let postImageView = "postImageView"
        static let stllImageView = "stllImageView"
        static let staffView = "staffView"
        static let addCommentView = "addCommentView"
        static let wishToWatchView = "보고싶어요"
        static let estimateView = "평가한영화"
        static let userCommentView = "내코멘트"
    }
}
