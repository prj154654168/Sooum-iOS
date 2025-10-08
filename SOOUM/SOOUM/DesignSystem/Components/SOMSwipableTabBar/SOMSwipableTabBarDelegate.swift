//
//  SOMSwipableTabBarDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/25.
//

import Foundation

protocol SOMSwipableTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: SOMSwipableTabBar, shouldSelectTabAt index: Int) -> Bool
    func tabBar(_ tabBar: SOMSwipableTabBar, didSelectTabAt index: Int)
}

extension SOMSwipableTabBarDelegate {
    func tabBar(_ tabBar: SOMSwipableTabBar, shouldSelectTabAt index: Int) -> Bool { true }
    func tabBar(_ tabBar: SOMSwipableTabBar, didSelectTabAt index: Int) { }
}
