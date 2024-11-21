//
//  SOMTransitioningDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 11/8/24.
//

import UIKit


class SOMTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    struct AssociatedKeys {
        static var transitioningDelegate = "BottomSheetTransitioningDelegate"
    }
    
    private var dismissWhenScreenDidTap: Bool
    private var isHandleBar: Bool
    private var isScrollable: Bool
    private var neverDismiss: Bool
    
    private var maxHeight: CGFloat?
    private var initalHeight: CGFloat
    
    let completion: (() -> Void)?
    
    weak var presentationController: UIPresentationController?


    init(
        dismissWhenScreenDidTap: Bool,
        isHandleBar: Bool,
        isScrollable: Bool,
        neverDismiss: Bool,
        maxHeight: CGFloat?,
        initalHeight: CGFloat,
        completion: (() -> Void)?
    ) {
        self.dismissWhenScreenDidTap = dismissWhenScreenDidTap
        self.isHandleBar = isHandleBar
        self.isScrollable = isScrollable
        self.neverDismiss = neverDismiss
        self.maxHeight = maxHeight
        self.initalHeight = initalHeight
        self.completion = completion
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
            isScrollable: self.isScrollable,
            neverDismiss: self.neverDismiss,
            maxHeight: self.maxHeight,
            initalHeight: self.initalHeight,
            completion: self.completion
        )
        self.presentationController = presentationController
        
        return presentationController
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        guard let presentedController = self.presentationController?.presentedViewController else { return }
        
        presentedController.dismiss(animated: animated, completion: completion)
    }
}
