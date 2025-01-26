//
//  UIImage.swift
//  SOOUM
//
//  Created by 오현식 on 11/19/24.
//

import UIKit

import Kingfisher


extension KingfisherManager {
    
    func download(strUrl: String?, completion: @escaping (UIImage?) -> Void) {
        
        if let strUrl = strUrl, let url = URL(string: strUrl) {
            // 캐시 만료 기간 하루로 설정
            let resource = Kingfisher.ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            self.retrieveImage(with: resource, options: [.memoryCacheExpiration(.days(1))]) { result in
                switch result {
                case let .success(result):
                    completion(result.image)
                case let .failure(error):
                    Log.error("Error download image failed with kingfisher \(error.localizedDescription)")
                    self.cancel(strUrl: strUrl)
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    func cancel(strUrl: String?) {
        
        if let strUrl = strUrl, let url = URL(string: strUrl) {
            
            self.downloader.cancel(url: url)
            self.cache.removeImage(forKey: url.absoluteString)
        }
    }
}
