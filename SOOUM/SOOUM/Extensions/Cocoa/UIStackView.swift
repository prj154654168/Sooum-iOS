//
//  UIStackView.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import UIKit

extension UIStackView {

    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
}
