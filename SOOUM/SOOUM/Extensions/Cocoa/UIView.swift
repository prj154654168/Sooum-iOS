//
//  UIView.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import UIKit

extension UIView {

    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
