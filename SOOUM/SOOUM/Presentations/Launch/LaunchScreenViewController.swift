//
//  LaunchScreenViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/24/24.
//

import UIKit

import ReactorKit
import RxSwift

import SnapKit
import Then


class LaunchScreenViewController: BaseViewController, View {
    
    let viewForAnimation = UIView().then {
        $0.backgroundColor = UIColor(hex: "#A2E3FF")
    }
    
    let imageView = UIImageView(image: .init(.logo)).then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .som.white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func setupConstraints() {
        self.view.backgroundColor = UIColor(hex: "#A2E3FF")
        
        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(self.view.safeAreaLayoutGuide.snp.centerY)
            $0.width.equalTo(235)
            $0.height.equalTo(45)
        }
        
        self.view.addSubview(self.viewForAnimation)
        self.viewForAnimation.snp.makeConstraints {
            $0.edges.equalTo(self.imageView)
        }
    }
    
    func bind(reactor: LaunchScreenViewReactor) {
        
        self.rx.viewDidLayoutSubviews
            .subscribe(with: self) { object, _ in
                object.animate(to: 45) { _ in
                    
                    let viewController = MainTabBarController()
                    viewController.reactor = reactor.reactorForMainTabBar()
                    object.view.window?.rootViewController = viewController
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    private func animate(to height: CGFloat, completion: @escaping ((Bool) -> Void)) {
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.2,
            options: [.beginFromCurrentState, .curveEaseOut],
            animations: {
                self.viewForAnimation.transform = .init(translationX: 0, y: height)
                self.view.layoutIfNeeded()
            },
            completion: completion
        )
    }
}
