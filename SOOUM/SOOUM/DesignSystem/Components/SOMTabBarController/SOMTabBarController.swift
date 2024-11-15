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
    
    weak var delegate: SOMTabBarControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-4)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(SOMTabBar.height)
        }
    }
}

extension SOMTabBarController: SOMTabBarDelegate {
    
    func tabBar(_ tabBar: SOMTabBar, didSelectTabAt index: Int) {
        
        let viewController = self.viewControllers[index]
        self.delegate?.tabBarController(self, didSelect: viewController)
        
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
    }
}
