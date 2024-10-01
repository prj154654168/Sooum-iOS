//
//  UIImgeView.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import UIKit

import Kingfisher


extension UIImageView {

    static let placeholder: UIImage? = UIColor.som.gray02.toImage
    static let label: UILabel = .init()

    func setImage(strUrl: String?) {
        
        /// Image load
        if let strUrl: String = strUrl, let url = URL(string: strUrl) {
            let header = AnyModifier { request in
                var req = request
                req.addValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjY5Mjk0MzMsImV4cCI6MTAxNzI2OTI5NDMzLCJzdWIiOiJBY2Nlc3NUb2tlbiIsImlkIjo2MjUwNDc5NzMyNTA1MTUxNTMsInJvbGUiOiJVU0VSIn0.aL4Tr3FaSwvu9hOQISAvGJfCHBGCV9jRo_BfTQkBssU", forHTTPHeaderField: "Authorization")
                return req
            }
            self.kf.setImage(with: url, options: [.requestModifier(header)]) { _ in
                /// Delete label if image loading is successful
                Self.label.removeFromSuperview()
            }
            self.backgroundColor = .clear
        } else {
            self.kf.cancelDownloadTask()
            /// Placeholder view
            self.image = Self.placeholder
            Self.label.text = "Loading..."
            Self.label.textColor = .som.white
            Self.label.typography = .init(
                fontContainer: Pretendard(size: 18, weight: .medium),
                lineHeight: 21.48,
                letterSpacing: -0.04
            )
            
            self.addSubview(Self.label)
            Self.label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                Self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                Self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        }
    }
}
