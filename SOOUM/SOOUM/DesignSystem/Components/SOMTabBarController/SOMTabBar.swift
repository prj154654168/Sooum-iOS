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
    func tabBar(_ tabBar: SOMTabBar, shouldSelectTabAt index: Int) -> Bool
    func tabBar(_ tabBar: SOMTabBar, didSelectTabAt index: Int)
}

class SOMTabBar: UIView {

    static let height: CGFloat = 58
    
    private var tabBarItemContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private let tabBarBackgroundView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 58 * 0.5
        $0.clipsToBounds = true
    }
    
    private let blurView = UIVisualEffectView().then {
        let blurEffect = UIBlurEffect(style: .regular)
        $0.effect = blurEffect
        $0.backgroundColor = UIColor.som.white.withAlphaComponent(0.7)
        $0.alpha = 0.9
    }
    
    var viewControllers: [UIViewController] = [] {
        didSet {
            guard self.viewControllers.isEmpty == false else { return }
            self.setTabBarItemConstraints()
            self.setupConstraints()
            self.didSelectTab(0)
        }
    }
    
    weak var delegate: SOMTabBarDelegate?
    
    private let width: CGFloat = UIScreen.main.bounds.width - 20 * 2
    
    private var selectedIndex: Int = -1
    private var prevSelectedIndex: Int = -1
    
    private var tabWidth: CGFloat {
        self.width / CGFloat(self.numberOfItems)
    }
    
    private var numberOfItems: Int {
        self.viewControllers.count
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
        
        self.tabBarBackgroundView.addSubview(self.blurView)
        self.blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.width)
            $0.height.equalTo(58)
        }
        
        self.tabBarBackgroundView.addSubview(self.tabBarItemContainer)
        self.tabBarItemContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
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
        }
    }
    
    private func didSelectTab(_ index: Int ) {
        
        guard index != self.selectedIndex else { return }
        self.delegate?.tabBar(self, didSelectTabAt: index)
        
        self.tabBarItemContainer.arrangedSubviews.enumerated().forEach {
            guard let tabView = $1 as? SOMTabBarItem else { return }
            ($0 == index ? tabView.tabBarItemSelected : tabView.tabBarItemNotSelected)()
        }
        
        self.prevSelectedIndex = self.selectedIndex
        self.selectedIndex = index
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touchArea = touches.first?.location(in: self).x else { return }
        let index = Int(floor(touchArea / self.tabWidth))
        if self.delegate?.tabBar(self, shouldSelectTabAt: index) ?? false {
            self.didSelectTab(index)
        }
    }
}
