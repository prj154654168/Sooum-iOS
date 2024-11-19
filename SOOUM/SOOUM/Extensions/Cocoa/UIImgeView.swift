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
        
        /// Image load
        if let strUrl: String = strUrl, let url = URL(string: strUrl) {
            self.kf.setImage(with: url)
            self.backgroundColor = .clear
        } else {
            self.kf.cancelDownloadTask()
            self.image = Self.placeholder
        }
    }
}
