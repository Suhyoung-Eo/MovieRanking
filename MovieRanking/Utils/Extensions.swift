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
        
        guard !link.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.image = UIImage(named: K.Image.noImage)
            }
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            // 캐시메모리에 이미지 있는 경우 캐시키로 url link 사용
            let cachedKey = NSString(string: link)
            if let cachedImage = ImageCacheManager.shared.object(forKey: cachedKey) {
                DispatchQueue.main.async {
                    self?.image = cachedImage
                }
                return
            }
            
            guard let url = URL(string: link) else { return }
            guard let data = try? Data(contentsOf: url) else { return }
            
            if let image = UIImage(data: data) {
                ImageCacheManager.shared.setObject(image, forKey: cachedKey)
                DispatchQueue.main.async {
                    self?.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self?.image = UIImage()
                }
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
        if releaseDts.isEmpty || releaseDts == " " {
            return URL(string: "\(K.Api.kmdbURL)\(Private.kmbdKey)&title=\(movieName)")
        } else {
            return URL(string: "\(K.Api.kmdbURL)\(Private.kmbdKey)&title=\(movieName)&releaseDts=\(releaseDts)")
        }
    }
    
    static func urlForMovieInfoApi(movieId: String, movieSeq: String) -> URL? {
        return URL(string: "\(K.Api.kmdbURL)\(Private.kmbdKey)&movieId=\(movieId)&movieSeq=\(movieSeq)")
    }
}

extension Bool {
    
    static func isDisplayNameValid(_ string: String?) -> Bool {
        guard let string = string, !string.isEmpty else { return false }
        let arr = Array(string)
        let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]$"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            var index = 0
            while index < arr.count { // string 내 각 문자 하나하나 마다 정규식 체크 후 충족하지 못한것은 제거.
                let results = regex.matches(in: String(arr[index]), options: [], range: NSRange(location: 0, length: 1))
                if results.count == 0 {
                    return false
                } else {
                    index += 1
                }
            }
            
        } catch {
            return false
        }
        
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
