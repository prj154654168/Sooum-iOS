//
//  Notification.swift
//  SOOUM
//
//  Created by 오현식 on 11/30/24.
//

import Foundation


extension Notification.Name {
    
    /// Update tabBarHidden
    static let hidesBottomBarWhenPushedDidChange = Notification.Name("hidesBottomBarWhenPushedDidChange")
    /// Update location auth state
    static let changedLocationAuthorization = Notification.Name("changedLocationAuthorization")
    /// Should scroll to top
    static let scollingToTopWithAnimation = Notification.Name("scollingToTopWithAnimation")
    /// Should reload
    static let reloadData = Notification.Name("reloadData")
}
