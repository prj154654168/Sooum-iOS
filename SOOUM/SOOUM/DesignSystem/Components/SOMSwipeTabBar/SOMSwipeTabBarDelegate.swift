//
//  SOMSwipeTabBarDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 12/22/24.
//

import Foundation


protocol SOMSwipeTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: SOMSwipeTabBar, shouldSelectTabAt index: Int) -> Bool
    func tabBar(_ tabBar: SOMSwipeTabBar, didSelectTabAt index: Int)
}
