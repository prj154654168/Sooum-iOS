//
//  UIImgeView.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import UIKit

import Kingfisher

import RxCocoa
import RxSwift


extension UIImageView {

    static let placeholder: UIImage? = UIColor.som.gray400.toImage

    func setImage(strUrl: String?) {
        
        if let strUrl: String = strUrl, let url = URL(string: strUrl) {
            // 캐싱된 이미지가 있다면, 먼저 사용
            ImageCache.default.retrieveImage(forKey: url.absoluteString) { result in
                switch result {
                case let .success(value):
                    if let image = value.image {
                        self.image = image
                    } else {
                        self.kf.setImage(
                            with: url,
                            placeholder: Self.placeholder,
                            options: [.transition(.fade(0.25))]
                        )
                    }
                case let .failure(error):
                    Log.error("Error download image failed with kingfisher: \(error.localizedDescription)")
                }
            }
            
            self.backgroundColor = .clear
        } else {
            self.kf.cancelDownloadTask()
            self.image = Self.placeholder
        }
    }
}
