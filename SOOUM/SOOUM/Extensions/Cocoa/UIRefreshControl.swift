//
//  UIRefreshControl.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import UIKit

extension UIRefreshControl {

    func beginRefreshingFromTop() {
        if let scrollView: UIScrollView = superview as? UIScrollView {
            /// refreshControl height + scrolled top inset
            let offset = CGPoint(x: 0, y: -(self.frame.size.height + scrollView.adjustedContentInset.top))
            scrollView.setContentOffset(offset, animated: true)
        }
        self.beginRefreshing()
        self.sendActions(for: .valueChanged)
    }
}
