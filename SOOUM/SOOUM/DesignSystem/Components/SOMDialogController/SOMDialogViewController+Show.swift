//
//  SOMDialogViewController+Show.swift
//  SOOUM
//
//  Created by 오현식 on 12/7/24.
//

import UIKit


extension SOMDialogViewController {
    
    @discardableResult
    static func show(
        title: String,
        subTitle: String,
        leftAction: Action? = nil,
        rightAction: Action?,
        dimViewAction: Action? = nil,
        completion: ((SOMDialogViewController) -> Void)? = nil
    ) -> SOMDialogViewController {
        
        return self.show { window in
            
            let dialogViewController = SOMDialogViewController()
            dialogViewController.setData(
                title: title,
                subTitle: subTitle,
                leftAction: leftAction,
                rightAction: rightAction,
                dimViewAction: dimViewAction,
                completion: { dialogViewController in
                    window.windowScene = nil
                    completion?(dialogViewController)
                }
            )
            
            return dialogViewController
        }
    }
    
    static func show<T: UIViewController>(_ closure: (UIWindow) -> T) -> T {
        
        let rootViewController = UIViewController()
        
        let window: UIWindow = {
            let scenes: Set = UIApplication.shared.connectedScenes
            let activeScene: UIScene? = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
            if let scene: UIWindowScene = activeScene as? UIWindowScene {
                return .init(windowScene: scene)
            } else {
                return .init(frame: UIScreen.main.bounds)
            }
        }()
        
        window.windowLevel = .alert
        window.backgroundColor = .clear
        window.rootViewController = rootViewController
        
        window.makeKeyAndVisible()
        
        let dialogViewController: T = closure(window)
        dialogViewController.modalTransitionStyle = .crossDissolve
        dialogViewController.modalPresentationStyle = .overFullScreen
        
        rootViewController.present(dialogViewController, animated: true, completion: nil)
        
        return dialogViewController
    }
}
