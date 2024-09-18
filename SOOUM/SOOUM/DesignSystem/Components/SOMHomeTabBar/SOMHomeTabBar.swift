//
//  SOMHomeTabBar.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/24.
//

import UIKit

import SnapKit
import Then


protocol SOMHomeTabBarDelegate: AnyObject {
     func tabBar(_ tabBar: SOMHomeTabBar, didSelectTabAt index: Int)
}

class SOMHomeTabBar: UIView {
    
    enum Title: String, CaseIterable {
        case latest = "최신순"
        case popularity = "인기순"
        case distance = "거리순"
    }
    
    static let height: CGFloat = 40
    
    private let homeTabBarItemContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.isLayoutMarginsRelativeArrangement = true
        $0.spacing = 2
    }
    
    weak var delegate: SOMHomeTabBarDelegate?
    
    private var selectedIndex: Int = 0
    private var prevSelectedIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
        self.didSelectTab(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let backgroudView = UIView()
        
        Title.allCases.forEach {
            let homeTabBarItem = SOMHomeTabBarItem()
            homeTabBarItem.text = $0.rawValue
            self.homeTabBarItemContainer.addArrangedSubview(homeTabBarItem)
        }
        
        backgroudView.addSubview(self.homeTabBarItemContainer)
        self.homeTabBarItemContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        let bottomSeperator = UIView().then {
            $0.backgroundColor = .som.gray02
        }
        backgroudView.addSubview(bottomSeperator)
        bottomSeperator.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.addSubview(backgroudView)
        backgroudView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func didSelectTab(_ index: Int) {
        
        guard index + 1 != selectedIndex else { return }
        self.homeTabBarItemContainer.arrangedSubviews.enumerated().forEach {
            guard let homeTabView = $1 as? SOMHomeTabBarItem else { return }
            if $0 == index {
                homeTabView.homeTabBarItemSelected()
            } else {
                homeTabView.homeTabBarItemNotSelected()
            }
        }

        self.prevSelectedIndex = self.selectedIndex
        self.selectedIndex = index + 1

        self.delegate?.tabBar(self, didSelectTabAt: index)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let touchArea = touches.first?.location(in: self) else { return }
        
        if self.homeTabBarItemContainer.frame.contains(touchArea) {
            let convertTouchAreaInContainer = convert(touchArea, to: self.homeTabBarItemContainer).x
            let index = Int(floor(convertTouchAreaInContainer / SOMHomeTabBarItem.width))
            self.didSelectTab(index)
        }
    }
}
