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
    /// Updated favorite
    static let addedFavoriteWithCardId = Notification.Name("addedFavoriteWithCardId")
    /// Added comment
    static let addedCommentWithCardId = Notification.Name("addedCommentWithCardId")
    /// Deleted feed card
    static let deletedFeedCardWithId = Notification.Name("deletedFeedCardWithId")
    /// Deleted comment card
    static let deletedCommentCardWithId = Notification.Name("deletedCommentCardWithId")
    /// Updated block user
    static let updatedBlockUser = Notification.Name("updatedBlockUser")
    /// Updated hasUnreads
    static let updatedHasUnreadNotification = Notification.Name("updatedHasUnreadNotification")
    /// Should reload home
    static let reloadHomeData = Notification.Name("reloadHomeData")
    /// Should reload detail
    static let reloadDetailData = Notification.Name("reloadDetailData")
    /// Updated report state
    static let updatedReportState = Notification.Name("updatedReportState")
    /// Should reload progile
    static let reloadProfileData = Notification.Name("reloadProfileData")
    /// Should reload favorite tag
    static let reloadFavoriteTagData = Notification.Name("reloadFavoriteTagData")
}
