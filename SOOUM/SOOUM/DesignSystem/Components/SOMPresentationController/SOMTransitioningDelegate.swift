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
    
    private var isHandleBar: Bool
    private var neverDismiss: Bool
    
    private var maxHeight: CGFloat?
    private var initalHeight: CGFloat
    
    let completion: (() -> Void)?
    
    weak var presentationController: UIPresentationController?


    init(
        isHandleBar: Bool,
        neverDismiss: Bool,
        maxHeight: CGFloat?,
        initalHeight: CGFloat,
        completion: (() -> Void)?
    ) {
        self.isHandleBar = isHandleBar
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
            isHandleBar: self.isHandleBar,
            neverDismiss: self.neverDismiss,
            maxHeight: self.maxHeight,
            initalHeight: self.initalHeight,
            completion: self.completion
        )
        self.presentationController = presentationController
        
        return presentationController
    }
    
    func dismiss(animated: Bool) {
        guard let presentedController = self.presentationController?.presentedViewController else { return }
        
        presentedController.dismiss(animated: animated)
    }
}
