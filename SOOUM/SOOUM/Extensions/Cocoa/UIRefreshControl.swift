//
//  UIRefreshControl.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import UIKit

extension UIRefreshControl {
    
    func beginRefreshingWithOffset(_ offset: CGFloat) {
        if let scrollView: UIScrollView = superview as? UIScrollView {
            scrollView.contentInset.top = offset
        }
        self.beginRefreshing()
    }
    
    func endRefreshingWithOffset() {
        
        if let scrollView: UIScrollView = superview as? UIScrollView {
            scrollView.contentInset.top = 0
        }
        self.endRefreshing()
    }
}
