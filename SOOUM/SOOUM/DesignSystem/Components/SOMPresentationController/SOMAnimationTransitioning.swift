//
//  SOMAnimationTransitioning.swift
//  SOOUM
//
//  Created by 오현식 on 12/9/24.
//

import UIKit


class SOMAnimationTransitioning: NSObject {
    
    private let transitionDuration: TimeInterval = 0.25
    
    private let initalHeight: CGFloat
    
    init(initalHeight: CGFloat) {
        self.initalHeight = initalHeight
    }
}

extension SOMAnimationTransitioning: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        
        return self.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        
        // 초기 위치 설정
        toView.frame = containerView.bounds
        toView.frame.origin.y = containerView.bounds.height
        containerView.addSubview(toView)
        
        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            
            toView.frame.origin.y = containerView.bounds.height - self.initalHeight
        } completion: { _ in
            transitionContext.completeTransition(transitionContext.transitionWasCancelled == false)
        }
    }
}
