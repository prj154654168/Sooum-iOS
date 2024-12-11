//
//  UIImage.swift
//  SOOUM
//
//  Created by 오현식 on 11/19/24.
//

import UIKit

import Kingfisher


extension UIImage {
    
    func resized(_ size: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        
        color.setFill()
        UIRectFillUsingBlendMode(CGRect(origin: .zero, size: size), .sourceIn)

        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func download(strUrl: String?, completion: @escaping (UIImage?) -> Void) {
        
        if let strUrl = strUrl, let url = URL(string: strUrl) {
            
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case let .success(result):
                    completion(result.image)
                case let .failure(error):
                    print("❌ Download image failed with kingfisher \(error.localizedDescription)")
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
            
            KingfisherManager.shared.downloader.cancel(url: url)
            KingfisherManager.shared.cache.removeImage(forKey: url.absoluteString)
        }
    }
}
