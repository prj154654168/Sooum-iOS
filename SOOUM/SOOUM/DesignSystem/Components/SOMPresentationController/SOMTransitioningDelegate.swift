//
//  SOMTransitioningDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 11/8/24.
//

import UIKit


class SOMTransitioningDelegate: NSObject {
    
    private var dismissWhenScreenDidTap: Bool
    private var isHandleBar: Bool
    private var neverDismiss: Bool
    
    private var maxHeight: CGFloat?
    private var initalHeight: CGFloat
    
    let completion: (() -> Void)?
    
    weak var presentationController: UIPresentationController?


    init(
        dismissWhenScreenDidTap: Bool,
        isHandleBar: Bool,
        neverDismiss: Bool,
        maxHeight: CGFloat?,
        initalHeight: CGFloat,
        completion: (() -> Void)?
    ) {
        self.dismissWhenScreenDidTap = dismissWhenScreenDidTap
        self.isHandleBar = isHandleBar
        self.neverDismiss = neverDismiss
        self.maxHeight = maxHeight
        self.initalHeight = initalHeight
        self.completion = completion
    }

    
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        
        self.presentationController?.presentedViewController.dismiss(
            animated: animated,
            completion: completion
        )
    }
}

extension SOMTransitioningDelegate {
    
    struct AssociatedKeys {
        static var transitioningDelegate = UInt8(0)
    }
}

extension SOMTransitioningDelegate: UIViewControllerTransitioningDelegate {
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        
        return SOMAnimationTransitioning(initalHeight: self.initalHeight)
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        return nil
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        
        let presentationController = SOMPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            dismissWhenScreenDidTap: self.dismissWhenScreenDidTap,
            isHandleBar: self.isHandleBar,
            neverDismiss: self.neverDismiss,
            maxHeight: self.maxHeight,
            initalHeight: self.initalHeight,
            completion: self.completion
        )
        self.presentationController = presentationController
        
        return presentationController
    }
}
