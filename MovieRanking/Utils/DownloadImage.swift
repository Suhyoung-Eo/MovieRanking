//
//  DownloadImage.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

class DownloadImage {
    
    static let shared = DownloadImage()
    
    func download(from link: String, completion: @escaping (UIImage?) -> Void) {
        
        guard !link.isEmpty else { completion(nil); return }
        
        // 캐시메모리에 이미지 있는 경우 캐시키로 url link 사용
        let cachedKey = NSString(string: link)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cachedKey) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: link) else { completion(nil); return }
        guard let data = try? Data(contentsOf: url) else { completion(nil); return }
        
        if let image = UIImage(data: data) {
            completion(image)
            ImageCacheManager.shared.setObject(image, forKey: cachedKey)
        } else {
            completion(nil)
        }
    }
    
    private init() {}
}
