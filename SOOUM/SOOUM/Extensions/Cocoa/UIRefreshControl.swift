//
//  UIRefreshControl.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import UIKit

extension UIRefreshControl {
    
    func beginRefreshingWithOffset(_ offset: CGFloat) {
        self.bounds.origin.y = -offset
        self.beginRefreshing()
    }
}
