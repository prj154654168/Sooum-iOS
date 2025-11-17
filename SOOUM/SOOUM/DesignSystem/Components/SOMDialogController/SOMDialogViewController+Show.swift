//
//  SOMDialogViewController+Show.swift
//  SOOUM
//
//  Created by 오현식 on 12/7/24.
//

import UIKit


extension SOMDialogViewController {
    
    private static weak var displayedDialogViewController: SOMDialogViewController?
    
    @discardableResult
    static func show(
        title: String,
        message: String,
        textAlignment: NSTextAlignment = .center,
        actions: [SOMDialogAction],
        dismissesWhenBackgroundTouched: Bool = false,
        completion: ((SOMDialogViewController) -> Void)? = nil
    ) -> SOMDialogViewController {
        
        return self.show { window in
            
            let dialogViewController = SOMDialogViewController(
                title: title,
                message: message,
                textAlignment: textAlignment,
                completion: { alertController in
                    window.windowScene = nil
                    /// Dismiss 된 alertController와 표시되었던 dialog가 같다면 제거
                    if alertController == Self.displayedDialogViewController {
                        Self.displayedDialogViewController = nil
                    }
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
        messageView: UIView?,
        textAlignment: NSTextAlignment = .center,
        actions: [SOMDialogAction],
        dismissesWhenBackgroundTouched: Bool = false,
        completion: ((SOMDialogViewController) -> Void)? = nil
    ) -> SOMDialogViewController {
        
        return self.show { window in
            
            let dialogViewController = SOMDialogViewController(
                title: title,
                messageView: messageView,
                textAlignment: textAlignment,
                completion: { alertController in
                    window.windowScene = nil
                    /// Dismiss 된 alertController와 표시되었던 dialog가 같다면 제거
                    if alertController == Self.displayedDialogViewController {
                        Self.displayedDialogViewController = nil
                    }
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
        
        /// 현재 표시된 dialog가 있다면 dismiss
        if let displayedDialogViewController = Self.displayedDialogViewController {
            displayedDialogViewController.dismiss(animated: false, completion: nil)
            Self.displayedDialogViewController = nil
        }
        
        window.windowLevel = .alert
        window.backgroundColor = .clear
        window.rootViewController = rootViewController
        
        window.makeKeyAndVisible()
        
        let dialogViewController: T = closure(window)
        dialogViewController.modalTransitionStyle = .crossDissolve
        dialogViewController.modalPresentationStyle = .overFullScreen
        
        rootViewController.present(dialogViewController, animated: true, completion: nil)
        
        /// 표시될 dialog 저장
        if let willDisplayDialogViewController = dialogViewController as? SOMDialogViewController {
            self.displayedDialogViewController = willDisplayDialogViewController
        }
        
        return dialogViewController
    }
}
