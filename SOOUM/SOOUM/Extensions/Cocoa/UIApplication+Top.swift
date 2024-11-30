//
//  UIApplication+Top.swift
//  SOOUM
//
//  Created by 오현식 on 11/28/24.
//

import UIKit


extension UIApplication {

    var currentWindow: UIWindow? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first { $0.isKeyWindow }
    }

    var topViewController: UIViewController? {
        var top = self.currentWindow?.rootViewController
        while true {
            if let presented: UIViewController = top?.presentedViewController {
                top = presented
            } else if let nav: UINavigationController = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab: SOMTabBarController = top as? SOMTabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }

    static var currentWindow: UIWindow? {
        return self.shared.currentWindow
    }

    static var topViewController: UIViewController? {
        return self.shared.topViewController
    }
}
