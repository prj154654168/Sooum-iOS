//
//  SOMStickyTabBarDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 12/22/24.
//

import Foundation


protocol SOMStickyTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: SOMStickyTabBar, shouldSelectTabAt index: Int) -> Bool
    func tabBar(_ tabBar: SOMStickyTabBar, didSelectTabAt index: Int)
}

extension SOMStickyTabBarDelegate {
    func tabBar(_ tabBar: SOMStickyTabBar, shouldSelectTabAt index: Int) -> Bool { true }
    func tabBar(_ tabBar: SOMStickyTabBar, didSelectTabAt index: Int) { }
}
