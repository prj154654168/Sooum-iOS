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

    static let placeholder: UIImage? = UIColor.som.v2.pMain.toImage

    func setImage(strUrl: String?, with key: String) {
        
        if let strUrl: String = strUrl, let url = URL(string: strUrl) {
            /// ImageResource 객체를 생성하여 URL과 Cache Key를 연결
            let resource = KF.ImageResource(downloadURL: url, cacheKey: key)
            /// Kingfisher에 Resource를 전달하고 모든 캐시/다운로드 로직 위임
            self.kf.setImage(with: resource)
            self.backgroundColor = .clear
        } else {
            self.kf.cancelDownloadTask()
            self.image = Self.placeholder
        }
    }
}
