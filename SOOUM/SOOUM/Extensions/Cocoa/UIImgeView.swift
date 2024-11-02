//
//  UIImgeView.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import UIKit

import Kingfisher


extension UIImageView {

    static let placeholder: UIImage? = UIColor.som.gray400.toImage
    static let label: UILabel = .init()

    func setImage(strUrl: String?) {
        
        /// Image load
        if let strUrl: String = strUrl, let url = URL(string: strUrl) {
            self.kf.setImage(with: url) { _ in
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
                fontContainer: BuiltInFont(size: 18, weight: .medium),
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
