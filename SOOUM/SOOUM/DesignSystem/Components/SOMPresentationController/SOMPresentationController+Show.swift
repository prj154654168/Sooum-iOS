//
//  SOMPresentationController+Present.swift
//  SOOUM
//
//  Created by 오현식 on 11/8/24.
//

import UIKit


extension UIViewController {
    
    func showBottomSheet(
        presented presentedViewController: UIViewController,
        dismissWhenScreenDidTap: Bool = false,
        isHandleBar: Bool,
        neverDismiss: Bool,
        maxHeight: CGFloat? = nil,
        initalHeight: CGFloat,
        completion: (() -> Void)? = nil
    ) {
        
        let transitioningDelegate = SOMTransitioningDelegate(
            dismissWhenScreenDidTap: dismissWhenScreenDidTap,
            isHandleBar: isHandleBar,
            neverDismiss: neverDismiss,
            maxHeight: maxHeight,
            initalHeight: initalHeight,
            completion: completion
        )
        
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.transitioningDelegate = transitioningDelegate
        
        withUnsafePointer(to: SOMTransitioningDelegate.AssociatedKeys.transitioningDelegate) {
            objc_setAssociatedObject(
                presentedViewController,
                $0,
                transitioningDelegate,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        self.present(presentedViewController, animated: true)
    }
    
    func dismissBottomSheet(animated: Bool = true, completion: (() -> Void)? = nil) {
        
        withUnsafePointer(to: SOMTransitioningDelegate.AssociatedKeys.transitioningDelegate) {
            if let transitioningDelegate = objc_getAssociatedObject(
                self,
                $0
            ) as? SOMTransitioningDelegate {
                transitioningDelegate.dismiss(animated: animated, completion: completion)
            } else {
                self.dismiss(animated: animated, completion: completion)
            }
        }
    }
}
