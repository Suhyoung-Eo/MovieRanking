//
//  ImageDownloadService.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/06.
//

import UIKit

class ImageDownloadService {
    
    static let shared = ImageDownloadService()
    
    func download(from link: String, completion: @escaping (UIImage?) -> Void) {
        
        if !link.isEmpty {
            
            let cachedKey = NSString(string: link)
            
            if let cachedImage = ImageCacheManager.shared.object(forKey: cachedKey) {
                completion(cachedImage)
                return
            }
            
            guard let url = URL(string: link) else { return }
            guard let data = try? Data(contentsOf: url) else {
                completion(nil)
                return
            }
            
            if let image = UIImage(data: data) {
                completion(image)
                ImageCacheManager.shared.setObject(image, forKey: cachedKey)
            } else {
                completion(nil)
            }
        }
    }
    
    private init() {}
}
