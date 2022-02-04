//
//  Extensions.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import UIKit

class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}

extension UIImageView {
    
    func setImage(from link: String) {
        
        if !link.isEmpty {
            DispatchQueue.global(qos: .background).async { [weak self] in
                // 캐시키로 url link 사용
                let cachedKey = NSString(string: link)
                
                if let cachedImage = ImageCacheManager.shared.object(forKey: cachedKey) {
                    DispatchQueue.main.async {
                        self?.image = cachedImage
                    }
                    return
                }
                
                guard let url = URL(string: link) else { return }
                
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    
                    guard let data = data, error == nil else {
                        DispatchQueue.main.async {
                            print("Failed download image from Url", error as Any)
                            self?.image = UIImage()
                        }
                        return
                    }
                    
                    if let image = UIImage(data: data) {
                        ImageCacheManager.shared.setObject(image, forKey: cachedKey)
                        
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }.resume()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.image = UIImage(named: K.Image.noImage)
            }
        }
    }
}

extension URL {
    
    static func urlForBoxOfficeApi(targetDt boxOfficeDay: String) -> URL? {
        return URL(string: "\(K.Api.koficDailyBoxOfficeListURL)\(Private.koficKey)&targetDt=\(boxOfficeDay)")
    }
    
    static func urlForBoxOfficeApi(weekGb boxOfficeType: Int, targetDt boxOfficeDay: String) -> URL? {
        return URL(string: "\(K.Api.koficWeeklyBoxOfficeListURL)\(Private.koficKey)&weekGb=\(boxOfficeType)&targetDt=\(boxOfficeDay)")
    }
    
    static func urlForMovieInfoApi(movieName: String) -> URL? {
        return URL(string: "\(K.Api.kmdbURL)\(Private.kmbdKey)&listCount=500&title=\(movieName)")
    }
    
    static func urlForMovieInfoApi(movieName: String, releaseDts: String) -> URL? {
        return URL(string: "\(K.Api.kmdbURL)\(Private.kmbdKey)&listCount=500&title=\(movieName)&releaseDts=\(releaseDts)")
    }
}
