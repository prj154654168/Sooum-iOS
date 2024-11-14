//
//  SOMPresentationController.swift
//  SOOUM
//
//  Created by 오현식 on 11/8/24.
//

import UIKit


class SOMPresentationController: UIPresentationController {
    
    private let screenView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let shadowView: UIView = {
        let view = UIView()
        view.alpha = 0
        
        view.layer.cornerRadius = 20
        
        view.layer.shadowColor = UIColor(hex: "#000000").withAlphaComponent(0.12).cgColor
        view.layer.shadowOpacity = 0
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8.4
        
        return view
    }()
    
    private var dismissWhenScreenDidTap: Bool
    private var isHandleBar: Bool
    private var neverDismiss: Bool
    
    private var maxHeight: CGFloat
    private var initalHeight: CGFloat
    private var currentHeight: CGFloat
    
    let completion: (() -> Void)?
    
    
    // MARK: Init
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
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
        
        self.maxHeight = maxHeight ?? initalHeight
        self.initalHeight = initalHeight
        self.currentHeight = initalHeight
        
        self.screenView.backgroundColor = self.currentHeight == self.maxHeight ? .som.dim : .clear
        
        self.completion = completion
        
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        
        if isHandleBar {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture))
            self.presentedView?.addGestureRecognizer(panGesture)
        }
        
        if dismissWhenScreenDidTap {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.screenDidTap))
            self.screenView.addGestureRecognizer(tapGesture)
        }
    }
    
    
    // MARK: Override Method
    
    // ContainerView에 넣어질 presentedView의 frame 설정
    override var frameOfPresentedViewInContainerView: CGRect {
        
        return self.updateFrame()
    }
    
    // PresentedView가 표시될 때 애니메이션 설정
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = self.containerView else { return }
        
        containerView.insertSubview(self.screenView, at: 0)
        
        if let presentedView = self.presentedViewController.view {
            presentedView.layer.cornerRadius = 20
            presentedView.clipsToBounds = true
            
            containerView.addSubview(self.shadowView)
            self.shadowView.layer.shadowPath = UIBezierPath(
                roundedRect: presentedView.bounds,
                cornerRadius: 20
            ).cgPath
        }
        
        if let coordinator = self.presentedViewController.transitionCoordinator {
            coordinator.animate { [weak self] _ in
                self?.updateScreenColor(self?.currentHeight == self?.maxHeight ? .som.dim : .clear)
                self?.shadowView.alpha = 1
                self?.shadowView.layer.shadowOpacity = 1
            }
        }
    }
    
    // SubView의 레이아웃 설정
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
        guard let containerView = self.containerView else { return }
        
        let isScreenInteraction = self.currentHeight != self.maxHeight
        let frame = self.updateFrame()
        
        containerView.frame = isScreenInteraction ? frame : UIScreen.main.bounds
        self.screenView.frame = containerView.bounds
        self.shadowView.frame = isScreenInteraction ? containerView.bounds : frame
        self.presentedView?.frame = isScreenInteraction ? containerView.bounds : frame
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        guard let coordinator = self.presentedViewController.transitionCoordinator else { return }
        coordinator.animate { [weak self] _ in
            self?.screenView.alpha = 0
            self?.shadowView.alpha = 0
            self?.shadowView.layer.shadowOpacity = 0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        self.completion?()
    }
    
    
    // MARK: Private Func
    
    private func updateHeight(_ height: CGFloat, animated: Bool = true) {
        
        guard self.isHandleBar, self.currentHeight != height else { return }
        self.currentHeight = height
        if self.currentHeight == 0 { self.presentedViewController.dismiss(animated: true) }
        
        let animationDuration: TimeInterval = animated ? 0.25 : 0
        UIView.animate(withDuration: animationDuration) {
            
            let isMax = self.currentHeight == self.maxHeight
            self.updateScreenColor(isMax ? .som.dim : .clear)
            
            self.containerViewDidLayoutSubviews()
        }
    }
    
    private func updateFrame() -> CGRect {
        
        let offsetY = UIScreen.main.bounds.size.height - self.currentHeight
        let width = UIScreen.main.bounds.size.width
        let frame = CGRect(
            origin: .init(x: 0, y: offsetY),
            size: .init(width: width, height: self.currentHeight)
        )
        return frame
    }
    
    private func updateScreenColor(_ color: UIColor) {
        
        self.screenView.isHidden = color == .clear
        self.screenView.alpha = color == .clear ? 0 : 1
        self.screenView.backgroundColor = color
    }
    
    
    // MARK: Gesture
    
    @objc
    private func screenDidTap(_ sender: UITapGestureRecognizer) {
        self.presentedViewController.dismiss(animated: true)
    }
    
    @objc
    private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView = self.presentedViewController.view else { return }
        
        let translation = gesture.translation(in: presentedView)
        
        /*
            항상 최대 높이는 maxheight
            neverDismiss == true 일 때, 최소 높이는 initalHeight
            neverDismiss == false 일 때, 최소 높이는 0, dismiss
            위로 스크롤 시
             - currentHeight > initalHeight + (maxHeight - inialHeight) * 0.5 이면, currentHeight = maxHeight
            아래로 스크롤 시
             - currentHeight < initalHeight * 0.5 이면, currentHeight = 0 or initalHeight
         */
        let velocity = gesture.velocity(in: presentedView)
        let scrollDirection = velocity.y < 0 ? "top" : "bottom"
        let newHeight = self.currentHeight - translation.y
        switch gesture.state {
        case .changed:
            if scrollDirection == "top" {
                self.updateHeight(min(self.maxHeight, newHeight))
            } else {
                self.updateHeight(max(self.neverDismiss ? self.initalHeight : 0, newHeight))
            }
        case .ended:
            if scrollDirection == "top" {
                let isMax = newHeight > self.initalHeight + (self.maxHeight - self.initalHeight) * 0.5
                let updateHeight = isMax ? self.maxHeight : self.initalHeight
                self.updateHeight(updateHeight)
            } else {
                let isMin = newHeight < self.initalHeight * 0.5 ? 0 : self.initalHeight
                let updateHeight = (isMin == 0 && self.neverDismiss) ? self.initalHeight : isMin
                self.updateHeight(updateHeight)
            }
        default:
            break
        }
    }
}
