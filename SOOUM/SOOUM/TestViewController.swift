//
//  TestViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/24.
//

import UIKit

import SnapKit


class TestViewController: UIViewController {
    
    let homeTabBar = SOMHomeTabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTabBar.delegate = self
        
        self.view.addSubview(self.homeTabBar)
        self.homeTabBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(SOMHomeTabBar.height)
        }
    }
}

extension TestViewController: SOMHomeTabBarDelegate {
    
    func tabBar(_ tabBar: SOMHomeTabBar, didSelectTabAt index: Int) {
        print("@@@@", index)
    }
}
