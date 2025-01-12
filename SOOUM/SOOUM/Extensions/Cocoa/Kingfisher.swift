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
            
            self.retrieveImage(with: url) { result in
                switch result {
                case let .success(result):
                    completion(result.image)
                case let .failure(error):
                    Log.error("Download image failed with kingfisher \(error.localizedDescription)")
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
