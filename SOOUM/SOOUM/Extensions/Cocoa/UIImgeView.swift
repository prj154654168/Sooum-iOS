//
//  UIImgeView.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import UIKit

import Kingfisher


extension UIImageView {

    static let placeholder: UIImage? = UIColor.som.white.toImage

    func setImage(strUrl: String?) {

        if let strUrl: String = strUrl, let url = URL(string: strUrl) {
            let header = AnyModifier { request in
                var req = request
                req.addValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjY5Mjk0MzMsImV4cCI6MTAxNzI2OTI5NDMzLCJzdWIiOiJBY2Nlc3NUb2tlbiIsImlkIjo2MjUwNDc5NzMyNTA1MTUxNTMsInJvbGUiOiJVU0VSIn0.aL4Tr3FaSwvu9hOQISAvGJfCHBGCV9jRo_BfTQkBssU", forHTTPHeaderField: "Authorization")
                return req
            }
            self.kf.setImage(with: url, options: [.requestModifier(header)])
            self.backgroundColor = .clear
        } else {
            self.kf.cancelDownloadTask()
            self.image = Self.placeholder
        }
    }
}
