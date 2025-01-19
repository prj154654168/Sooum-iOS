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
        message: String,
        actions: [SOMDialogAction],
        dismissesWhenBackgroundTouched: Bool = false,
        completion: ((SOMDialogViewController) -> Void)? = nil
    ) -> SOMDialogViewController {
        
        return self.show { window in
            
            let dialogViewController = SOMDialogViewController(
                title: title,
                message: message,
                completion: { alertController in
                    window.windowScene = nil
                    completion?(alertController)
                }
            )
            dialogViewController.dismissesWhenBackgroundTouched = dismissesWhenBackgroundTouched
            actions.forEach(dialogViewController.setAction)
            
            return dialogViewController
        }
    }
    
    @discardableResult
    static func show(
        title: String,
        messageView: UIView,
        actions: [SOMDialogAction],
        dismissesWhenBackgroundTouched: Bool = false,
        completion: ((SOMDialogViewController) -> Void)? = nil
    ) -> SOMDialogViewController {
        
        return self.show { window in
            
            let dialogViewController = SOMDialogViewController(
                title: title,
                messageView: messageView,
                completion: { alertController in
                    window.windowScene = nil
                    completion?(alertController)
                }
            )
            dialogViewController.dismissesWhenBackgroundTouched = dismissesWhenBackgroundTouched
            actions.forEach(dialogViewController.setAction)
            
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
