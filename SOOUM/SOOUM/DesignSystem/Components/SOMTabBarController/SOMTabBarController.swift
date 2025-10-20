//
//  SOMTabBarController.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/24.
//

import UIKit

import SnapKit
import Then

protocol SOMTabBarControllerDelegate: AnyObject {
    
    func tabBarController(
        _ tabBarController: SOMTabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool
    
    
    func tabBarController(
        _ tabBarController: SOMTabBarController,
        didSelect viewController: UIViewController
    )
}

class SOMTabBarController: UIViewController {
    
    private lazy var tabBar = SOMTabBar().then {
        $0.delegate = self
    }
    
    private lazy var container = UIView().then {
        $0.backgroundColor = .som.white
    }
    
    var viewControllers: [UIViewController] = [] {
        didSet { self.tabBar.viewControllers = self.viewControllers }
    }
    
    private var selectedIndex: Int = -1
    var selectedViewController: UIViewController?
    
    weak var delegate: SOMTabBarControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.hidesBottomBarWhenPushed(_:)),
            name: .hidesBottomBarWhenPushedDidChange,
            object: nil
        )
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        
        self.view.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.tabBar)
        self.view.bringSubviewToFront(self.tabBar)
        self.tabBar.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalTo(88)
        }
    }
    
    @objc
    private func hidesBottomBarWhenPushed(_ notification: Notification) {
        
        // 탭바컨트롤러의 탭바의 숨김처리를 위해 추가
        guard let viewController = notification.object as? UIViewController,
              let selectedViewController = self.selectedViewController as? UINavigationController,
              viewController == selectedViewController.topViewController
        else { return }
        
        let hidesTabBar = viewController.hidesBottomBarWhenPushed
        // self.tabBar.isHidden = hidesTabBar
        UIView.animate(withDuration: 0.25) {
            self.tabBar.frame.origin.y = hidesTabBar ? self.view.frame.maxY : self.view.frame.maxY - 88
        }
    }
    
    func didSelectedIndex(_ index: Int) {
        
        self.tabBar.didSelectTabBarItem(index)
    }
}

extension SOMTabBarController: SOMTabBarDelegate {
    
    func tabBar(_ tabBar: SOMTabBar, shouldSelectTabAt index: Int) -> Bool {
        return self.delegate?.tabBarController(self, shouldSelect: self.viewControllers[index]) ?? true
    }
    
    func tabBar(_ tabBar: SOMTabBar, didSelectTabAt index: Int) {
        
        let viewController = self.viewControllers[index]
        
        if self.children.isEmpty == false {
            self.children.forEach {
                $0.willMove(toParent: nil)
                $0.view.removeFromSuperview()
                $0.removeFromParent()
            }
        }
        
        self.addChild(viewController)
        viewController.view.frame = self.container.bounds
        self.container.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        self.selectedIndex = index
        self.selectedViewController = viewController
        self.delegate?.tabBarController(self, didSelect: viewController)
    }
}
