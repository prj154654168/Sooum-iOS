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
        view.backgroundColor = .som.dim
        
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
    
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private var dismissWhenScreenDidTap: Bool
    private var isHandleBar: Bool
    private var neverDismiss: Bool
    
    private var maxHeight: CGFloat
    private var initalHeight: CGFloat
    private var currentHeight: CGFloat
    
    let completion: (() -> Void)?
    
    
    // MARK: Initalization
    
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
        
        self.completion = completion
        
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        
        if isHandleBar {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture))
            presentedViewController.view.addGestureRecognizer(panGesture)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleBarDidTap))
            self.handleBar.addGestureRecognizer(tapGesture)
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
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
        self.updateSubviewsFrame()
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
            
            if self.isHandleBar {
                presentedView.addSubview(self.handleBar)
                var size: CGSize = presentedView.frame.size
                size.height = 30
                self.handleBar.frame = .init(origin: .zero, size: size)
            }
        }
        
        if let coordinator = self.presentedViewController.transitionCoordinator {
            coordinator.animate { [weak self] _ in
                self?.screenView.alpha = (self?.currentHeight == self?.maxHeight ? 1 : 0)
                self?.shadowView.alpha = 1
                self?.shadowView.layer.shadowOpacity = 1
            }
        }
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
        
        self.screenView.removeFromSuperview()
        self.shadowView.removeFromSuperview()
        self.handleBar.removeFromSuperview()
        
        self.completion?()
    }
    
    
    // MARK: Private Func
    
    private func updateHeight(_ height: CGFloat, animated: Bool = true) {
        
        guard self.isHandleBar, self.currentHeight != height else { return }
        self.currentHeight = height
        if self.currentHeight == 0 { self.presentedViewController.dismiss(animated: true) }
        
        let isMax = self.currentHeight == self.maxHeight
        self.screenView.alpha = isMax ? 1 : 0
        
        self.updateSubviewsFrame(animated)
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
    
    private func updateSubviewsFrame(_ animated: Bool = true) {
        
        guard let containerView = self.containerView,
              let presentedView = self.presentedView
        else { return }
        
        let isScreenInteraction = self.currentHeight != self.maxHeight
        let frame = self.frameOfPresentedViewInContainerView
        
        containerView.frame = isScreenInteraction ? frame : UIScreen.main.bounds
        self.screenView.frame = containerView.bounds
        
        presentedView.frame = isScreenInteraction ? containerView.bounds : frame
        self.shadowView.frame = presentedView.bounds
    }
    
    
    // MARK: Gesture
    
    @objc
    private func screenDidTap(_ sender: UITapGestureRecognizer) {
        
        if self.currentHeight == self.initalHeight {
            self.presentedViewController.dismiss(animated: true)
        }
    }
    
    @objc
    private func handleBarDidTap(_ sender: UITapGestureRecognizer) {
        
        /*
            currentHeight == initalHeight 일 때, currentHeight = maxHeight
            currentHeight == maxHeight 일 때, currentHeight = initalHeight
         */
        if self.currentHeight == self.initalHeight {
            self.updateHeight(self.maxHeight)
        } else if self.currentHeight == self.maxHeight {
            self.updateHeight(self.initalHeight)
        }
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
                let isMax = newHeight > self.initalHeight + (self.maxHeight - self.initalHeight) * 0.8
                let updateHeight = isMax ? self.maxHeight : self.initalHeight
                self.updateHeight(updateHeight)
            } else {
                let isMin = newHeight < self.initalHeight * 0.8 ? 0 : self.initalHeight
                let updateHeight = (isMin == 0 && self.neverDismiss) ? self.initalHeight : isMin
                self.updateHeight(updateHeight)
            }
        default:
            break
        }
    }
}
