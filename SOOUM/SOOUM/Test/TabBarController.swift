//
//  TabBarController.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/24.
//

import UIKit

import SnapKit


class TabBarController: SOMTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        let firstVC = FirstVC()
        firstVC.tabBarItem = .init(
            title: "메인홈",
            image: .init(.icon(.outlined(.home))),
            selectedImage: nil
        )
        let secondVC = SecondVC()
        secondVC.tabBarItem = .init(
            title: "글추가",
            image: .init(.icon(.outlined(.addCard))),
            selectedImage: nil
        )
        let thirdVC = ThirdVC()
        thirdVC.tabBarItem = .init(
            title: "태그",
            image: .init(.icon(.outlined(.star))),
            selectedImage: nil
        )
        let fourthVC = FourthVC()
        fourthVC.tabBarItem = .init(
            title: "프로필",
            image: .init(.icon(.outlined(.profile))),
            selectedImage: nil
        )
        
        self.viewControllers = [firstVC, secondVC, thirdVC, fourthVC]
    }
}

extension TabBarController: SOMTabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: SOMTabBarController,
        didSelect viewController: UIViewController
    ) {
        print(viewController.tabBarItem.title ?? "")
    }
}
