//
//  SOMPresentationController+Present.swift
//  SOOUM
//
//  Created by 오현식 on 11/8/24.
//

import UIKit


extension UIViewController {
    
    func presentBottomSheet(
        presented viewController: UIViewController,
        isHandleBar: Bool,
        neverDismiss: Bool,
        maxHeight: CGFloat?,
        initalHeight: CGFloat,
        completion: (() -> Void)?
    ) {
        
        let transitioningDelegate = SOMTransitioningDelegate(
            isHandleBar: isHandleBar,
            neverDismiss: neverDismiss,
            maxHeight: maxHeight,
            initalHeight: initalHeight,
            completion: completion
        )
        
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitioningDelegate
        
        withUnsafePointer(to: SOMTransitioningDelegate.AssociatedKeys.transitioningDelegate) {
            objc_setAssociatedObject(
                viewController,
                $0,
                transitioningDelegate,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        self.present(viewController, animated: true)
    }
    
    func dismissBottomSheet(animated: Bool = true) {
        
        withUnsafePointer(to: SOMTransitioningDelegate.AssociatedKeys.transitioningDelegate) {
            if let transitioningDelegate = objc_getAssociatedObject(self, $0) as? SOMTransitioningDelegate {
                transitioningDelegate.dismiss(animated: animated)
            } else {
                self.dismiss(animated: animated)
            }
        }
    }
}
