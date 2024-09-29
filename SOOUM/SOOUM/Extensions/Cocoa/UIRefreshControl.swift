//
//  UIRefreshControl.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import UIKit

extension UIRefreshControl {

    func manualyBeginRefreshing() {
        if let scrollView: UIScrollView = superview as? UIScrollView {
            let offset = CGPoint(x: 0, y: -frame.size.height)
            scrollView.setContentOffset(offset, animated: true)
        }
        self.beginRefreshing()
        self.sendActions(for: .valueChanged)
    }
}
