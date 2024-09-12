//
//  SOMTabBar.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/24.
//

import UIKit

import SnapKit
import Then


protocol SOMTabBarDelegate: AnyObject {
     func tabBar(_ tabBar: SOMTabBar, didSelectTabAt index: Int)
}

class SOMTabBar: UIView {

    static let height: CGFloat = 60
    
    var viewControllers: [UIViewController] = [] {
        didSet {
            guard self.viewControllers.isEmpty == false else { return }
            self.setTabBarItemConstraints()
            self.setupConstraints()
            self.didSelectTab(0)
        }
    }
    
    var tabBarItemContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
        $0.layoutMargins = .init(top: 4, left: 4, bottom: 4, right: 4)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layer.cornerRadius = (60 - 4 * 2) * 0.5
    }
    
    let tabBarBackgroundView = UIView().then {
        $0.backgroundColor = .som.dim
        $0.layer.cornerRadius = 60 * 0.5
    }
    
    weak var delegate: SOMTabBarDelegate?
    
    private let width: CGFloat = UIScreen.main.bounds.width - 20 * 2
    
    private var selectedIndex: Int = 0
    private var prevSelectedIndex: Int = 0
    
    var numberOfItems: Int {
        self.viewControllers.count
    }
    
    var tabWidth: CGFloat {
        self.width / CGFloat(self.numberOfItems)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.tabBarBackgroundView.addSubview(self.tabBarItemContainer)
        self.tabBarItemContainer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.addSubview(self.tabBarBackgroundView)
        self.tabBarBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setTabBarItemConstraints() {
        
        self.viewControllers.forEach {
            let tabBarItem = SOMTabBarItem()
            tabBarItem.title = $0.tabBarItem.title
            tabBarItem.image = $0.tabBarItem.image
            self.tabBarItemContainer.addArrangedSubview(tabBarItem)
            tabBarItem.snp.makeConstraints {
                $0.width.equalTo(SOMTabBarItem.width)
                $0.height.equalTo(SOMTabBarItem.height)
            }
        }
    }
    
    private func didSelectTab(_ index: Int ) {
        
        guard index + 1 != selectedIndex else { return }
        self.tabBarItemContainer.arrangedSubviews.enumerated().forEach {
            guard let tabView = $1 as? SOMTabBarItem else { return }
            ($0 == index ? tabView.tabBarItemSelected : tabView.tabBarItemNotSelected)()
        }
        
        self.prevSelectedIndex = self.selectedIndex
        self.selectedIndex = index + 1
        
        self.delegate?.tabBar(self, didSelectTabAt: index)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touchArea = touches.first?.location(in: self).x else { return }
        let index = Int(floor(touchArea / self.tabWidth))
        self.didSelectTab(index)
    }
}
