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

    func setImage(strUrl: String?) {
        /// Placeholder view
        self.image = Self.placeholder
        self.backgroundColor = .clear
        
        var label: UILabel {
            let label = UILabel()
            label.text = "Loading..."
            label.textColor = .som.white
            label.typography = .init(
                fontContainer: Pretendard(size: 18, weight: .medium),
                lineHeight: 21.48,
                letterSpacing: -0.04
            )
            return label
        }
        
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)

        ])
        /// Image load
        if let strUrl: String = strUrl, let url = URL(string: strUrl) {
            let header = AnyModifier { request in
                var req = request
                req.addValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjY5Mjk0MzMsImV4cCI6MTAxNzI2OTI5NDMzLCJzdWIiOiJBY2Nlc3NUb2tlbiIsImlkIjo2MjUwNDc5NzMyNTA1MTUxNTMsInJvbGUiOiJVU0VSIn0.aL4Tr3FaSwvu9hOQISAvGJfCHBGCV9jRo_BfTQkBssU", forHTTPHeaderField: "Authorization")
                return req
            }
            self.kf.setImage(with: url, options: [.requestModifier(header)]) { _ in
                /// Delete label if image loading is successful
                label.removeFromSuperview()
            }
        } else {
            self.kf.cancelDownloadTask()
        }
    }
}
