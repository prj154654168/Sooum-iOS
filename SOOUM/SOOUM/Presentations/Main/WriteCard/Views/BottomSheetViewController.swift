//
//  BottomSheetViewController.swift
//  SOOUM
//
//  Created by 오현식 on 11/6/24.
//

import UIKit


class BottomSheetViewController: UIPresentationController {
    
    private lazy var screenView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private let shadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        
        view.layer.shadowColor = UIColor(hex: "#000000").withAlphaComponent(0.12).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8.4
        
        return view
    }()
    
    private var screenColor: UIColor?
    
    private var isScrolling: Bool
    private var neverDismiss: Bool
    
    private var handleViewHeight: CGFloat
    
    private var maxHeight: CGFloat
    private var initalHeight: CGFloat
    private var currentHeight: CGFloat
    
    let completion: (() -> Void)
    
    
    // MARK: Init
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        screenColor: UIColor?,
        neverDismiss: Bool,
        handleViewHeight: CGFloat,
        maxHeight: CGFloat?,
        initalHeight: CGFloat,
        completion: @escaping (() -> Void)
    ) {
        self.screenColor = screenColor
        
        self.isScrolling = false
        self.neverDismiss = neverDismiss
        
        self.handleViewHeight = handleViewHeight
        
        self.maxHeight = maxHeight ?? initalHeight
        self.initalHeight = initalHeight
        self.currentHeight = initalHeight
        
        self.completion = completion
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    
    // MARK: Override Method
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = self.containerView else { return .zero }
        
        let offsetY = containerView.bounds.size.height - self.currentHeight
        let width = containerView.bounds.size.width
        return CGRect(
            origin: .init(x: 0, y: offsetY),
            size: .init(width: width, height: self.currentHeight)
        )
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else { return }
        
        containerView.insertSubview(self.screenView, at: 0)
        self.screenView.frame = containerView.bounds
        
        if let presentedView = self.presentedViewController.view {
            presentedView.layer.cornerRadius = 20
            presentedView.clipsToBounds = true
            
            self.shadowView.layer.shadowPath = UIBezierPath(
                roundedRect: presentedView.bounds,
                cornerRadius: 20
            ).cgPath
            containerView.addSubview(self.shadowView)
            self.shadowView.frame = presentedView.bounds
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture))
            presentedView.addGestureRecognizer(panGesture)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else { return }
        coordinator.animate { [weak self] _ in
            self?.screenView.alpha = 0
        }
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
        self.screenView.frame = self.containerView?.bounds ?? .zero
        self.shadowView.frame = self.frameOfPresentedViewInContainerView
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    
    // MARK: Private Func
    
    private func updateHeight(_ height: CGFloat, animated: Bool = true) {
        
        // 현재 높이와 다르면 현재 높이를 업데이트
        guard self.currentHeight != height else { return }
        self.currentHeight = height
        
        let animationDuration: TimeInterval = animated ? 0.25 : 0
        UIView.animate(withDuration: animationDuration) {
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
            
            // 최대 높이와 초기 높이가 다를 때, 최대 높이가 되면 배경 dim 처리
            if self.maxHeight != self.initalHeight {
                let middle = self.initalHeight + (self.maxHeight - self.initalHeight) * 0.5
                self.screenView.backgroundColor = self.currentHeight >= middle ? UIColor(hex: "#000000").withAlphaComponent(0.5) : .clear
            }
        }
    }
    
    
    // MARK: Gesture
    
    @objc
    private func dismiss(_ gesture: UITapGestureRecognizer) {
        self.presentedViewController.dismiss(animated: true, completion: { self.completion() })
    }
    
    @objc
    private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView = self.presentedViewController.view else { return }
        
        let translation = gesture.translation(in: presentedView)
        
        switch gesture.state {
        case .began:
            self.isScrolling = true
        case .changed:
            if self.isScrolling {
                let newHeight = self.currentHeight - translation.y
                let updateHeight = min(self.maxHeight, max(self.initalHeight, newHeight))
                self.updateHeight(updateHeight, animated: false)
            }
        case .ended, .cancelled:
            self.isScrolling = false
        default:
            break
        }
    }
}

class BottomSheetTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    struct AssociatedKeys {
        static var transitioningDelegate = "BottomSheetTransitioningDelegate"
    }
    
    private let screenColor: UIColor?
    private let neverDismiss: Bool
    private let handleViewHeight: CGFloat
    private let maxHeight: CGFloat?
    private let initalHeight: CGFloat
    let completion: (() -> Void)
    
    
    init(
        screenColor: UIColor? = nil,
        neverDismiss: Bool,
        handleViewHeight: CGFloat,
        maxHeight: CGFloat? = nil,
        initalHeight: CGFloat,
        completion: @escaping (() -> Void)
    ) {
        self.screenColor = screenColor
        self.neverDismiss = neverDismiss
        self.handleViewHeight = handleViewHeight
        self.maxHeight = maxHeight
        self.initalHeight = initalHeight
        self.completion = completion
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        
        BottomSheetViewController(
            presentedViewController: presented,
            presenting: presenting,
            screenColor: self.screenColor,
            neverDismiss: self.neverDismiss,
            handleViewHeight: self.handleViewHeight,
            maxHeight: self.maxHeight,
            initalHeight: self.initalHeight,
            completion: completion
        )
    }
}

extension UIViewController {
    
    func presentBottomSheet(
        _ viewController: UIViewController,
        screenColor: UIColor?,
        neverDismiss: Bool,
        handleViewHeight: CGFloat,
        maxHeight: CGFloat?,
        initalHeight: CGFloat,
        completion: @escaping (() -> Void)
    ) {
        
        let transitioningDelegate = BottomSheetTransitionDelegate(
            screenColor: screenColor,
            neverDismiss: neverDismiss,
            handleViewHeight: handleViewHeight,
            maxHeight: maxHeight,
            initalHeight: initalHeight,
            completion: completion
        )
        
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitioningDelegate
        
        withUnsafePointer(to: BottomSheetTransitionDelegate.AssociatedKeys.transitioningDelegate) {
            objc_setAssociatedObject(
                viewController,
                $0,
                transitioningDelegate,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        self.present(viewController, animated: true)
    }
}
