//
//  UIImage.swift
//  SOOUM
//
//  Created by 오현식 on 11/19/24.
//

import UIKit

import Kingfisher


extension UIImage {
    
    static let placeholder: UIImage? = UIColor.som.gray400.toImage
    
    static func download(strUrl: String?, completion: @escaping (UIImage?) -> Void) {
        
        if let strUrl = strUrl, let url = URL(string: strUrl) {
            
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case let .success(result):
                    completion(result.image)
                case let .failure(error):
                    print("❌ Download image failed with kingfisher \(error.localizedDescription)")
                    completion(Self.placeholder)
                }
            }
        } else {
            completion(Self.placeholder)
        }
    }
}
