//
//  UIViewController+Toast.swift
//  SOOUM
//
//  Created by 오현식 on 12/14/24.
//

import UIKit

import ObjectiveC


extension UIViewController {
    
    func showToast(message: String, offset: CGFloat) {
        self.showToast(message: message, offset: offset, in: nil, displayDuration: 7)
    }
    
    func showToast(message: String, offset: CGFloat, in containerView: UIView?) {
        self.showToast(message: message, offset: offset, in: containerView, displayDuration: 7)
    }
    
    func showToast(
        message: String,
        offset: CGFloat,
        in containerView: UIView?,
        displayDuration: TimeInterval
    ) {
        guard let targetView = containerView ?? self.view else { return }
        targetView.layoutIfNeeded()
        
        targetView.som_currentToastView?.removeFromSuperview()
        
        let toastView = SOMBottomToastView(title: message, actions: nil)
        toastView.usesStandaloneStyle = true
        toastView.alpha = 0
        
        targetView.addSubview(toastView)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.bottomAnchor.constraint(
                equalTo: targetView.safeAreaLayoutGuide.bottomAnchor,
                constant: -offset
            ),
            toastView.centerXAnchor.constraint(equalTo: targetView.centerXAnchor)
        ])
        
        targetView.som_currentToastView = toastView
        targetView.bringSubviewToFront(toastView)
        
        UIView.animate(
            withDuration: 0.25,
            animations: {
                toastView.alpha = 1
            },
            completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) { [weak targetView, weak toastView] in
                    guard let targetView, let toastView else { return }
                    
                    UIView.animate(
                        withDuration: 0.25,
                        animations: {
                            toastView.alpha = 0
                        }, completion: { _ in
                            if targetView.som_currentToastView === toastView {
                                targetView.som_currentToastView = nil
                            }
                            toastView.removeFromSuperview()
                        }
                    )
                }
            }
        )
    }
}

private var somCurrentToastViewKey: UInt8 = 0

private extension UIView {
    
    var som_currentToastView: UIView? {
        get {
            objc_getAssociatedObject(self, &somCurrentToastViewKey) as? UIView
        }
        set {
            objc_setAssociatedObject(
                self,
                &somCurrentToastViewKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
