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
    
    
    // MARK: Views
    
    private var tabBarItemContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
        $0.spacing = 12
    }
    
    private let tabBarBackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.som.v2.gray200.cgColor
        $0.clipsToBounds = true
    }
    
    var viewControllers: [UIViewController] = [] {
        didSet {
            guard self.viewControllers.isEmpty == false else { return }
            self.setTabBarItemConstraints()
            self.didSelectTabBarItem(0)
        }
    }
    
    
    // MARK: Delegate
    
    weak var delegate: SOMTabBarDelegate?
    
    
    // MARK: Variables
    
    var itemSpacing: CGFloat {
        return (UIScreen.main.bounds.width - 16 * 2 - 77 * 4) / 3
    }
    
    var itemFrames: [CGRect] {
        var itemFrames: [CGRect] = []
        var currentX: CGFloat = 16
        let itemWidth: CGFloat = 77
        for _ in 0..<self.viewControllers.count {
            let itemFrame = CGRect(x: currentX, y: 0, width: itemWidth, height: self.bounds.height)
            itemFrames.append(itemFrame)
            currentX += itemWidth + self.itemSpacing
        }
        
        return itemFrames
    }
    
    private var selectedIndex: Int = -1
    private var prevSelectedIndex: Int = -1
    
    private var numberOfItems: Int {
        self.viewControllers.count
    }
    
    
    // MARK: initialize
    
    convenience init() {
        self.init(frame: .zero)
        
        self.setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        for (index, frame) in self.itemFrames.enumerated() {
            // 현재 선택한 좌표가 아이템의 내부일 때
            if frame.contains(location) {
                // 홈 탭을 다시 탭하면 scrollToTop
                if index == 0, self.selectedIndex == index {
                    NotificationCenter.default.post(name: .scollingToTopWithAnimation, object: self)
                }
                // 이전에 선택된 아이템이 아닐 때
                if self.selectedIndex != index {
                    // 선택할 수 있는 상태일 때
                    if self.delegate?.tabBar(self, shouldSelectTabAt: index) ?? true {
                        self.didSelectTabBarItem(index)
                    }
                }
            }
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.tabBarBackgroundView)
        self.tabBarBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.tabBarBackgroundView.addSubview(self.tabBarItemContainer)
        self.tabBarItemContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-34)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func setTabBarItemConstraints() {
        
        self.tabBarItemContainer.spacing = self.itemSpacing
        
        self.viewControllers.forEach {
            let tabBarItem = SOMTabBarItem(title: $0.tabBarItem.title, image: $0.tabBarItem.image)
            self.tabBarItemContainer.addArrangedSubview(tabBarItem)
        }
    }
    
    
    // MARK: Public func
    
    func didSelectTabBarItem(_ index: Int) {
        
        self.tabBarItemContainer.arrangedSubviews.enumerated().forEach {
            guard let tabView = $1 as? SOMTabBarItem else { return }
            ($0 == index ? tabView.tabBarItemSelected : tabView.tabBarItemNotSelected)()
        }
        
        self.prevSelectedIndex = self.selectedIndex
        self.selectedIndex = index
        self.delegate?.tabBar(self, didSelectTabAt: index)
    }
}
