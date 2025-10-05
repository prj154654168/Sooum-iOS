//
//  SOMStickyTabBar.swift
//  SOOUM
//
//  Created by 오현식 on 12/21/24.
//

import UIKit

import SnapKit
import Then


class SOMStickyTabBar: UIView {
    
    enum Constants {
        static let height: CGFloat = 56
        
        static let selectedColor: UIColor = UIColor.som.v2.black
        static let unSelectedColor: UIColor = UIColor.som.v2.gray400
    }
    
    
    // MARK: Views
    
    private let tabBarItemContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    private var tabBarItems: [UIView]? {
        let items = self.tabBarItemContainer.arrangedSubviews
        return items.isEmpty ? nil : items
    }
    
    private let bottomSeperator = UIView().then {
        $0.backgroundColor = .som.v2.gray200
    }
    
    
    // MARK: Variables
    
    var inset: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            self.refreshConstraints()
        }
    }
    
    var spacing: CGFloat = 24 {
        didSet {
            self.refreshConstraints()
        }
    }
    
    var items: [String] = [] {
        didSet {
            if self.items.isEmpty == false {
                self.setTabBarItems(self.items)
            }
        }
    }
    
    // Set item width with text and typography
    var itemWidths: [CGFloat] {
        let itemWidths: [CGFloat] = self.items.enumerated().map { index, item in
            let typography: Typography = .som.v2.title2
            /// 실제 텍스트 가로 길이
            return (item as NSString).size(withAttributes: [.font: typography.font]).width
        }
        
        return itemWidths
    }
    
    var itemFrames: [CGRect] {
        var itemFrames: [CGRect] = []
        var currentX: CGFloat = self.inset.left
        for itemWidth in self.itemWidths {
            let itemFrame = CGRect(x: currentX, y: 0, width: itemWidth, height: self.bounds.height)
            itemFrames.append(itemFrame)
            currentX += itemWidth + self.spacing
        }
        
        return itemFrames
    }
    
    var previousIndex: Int = 0
    var selectedIndex: Int = 0
    
    
    // MARK: Constraints
    
    private var tabBarItemContainerTopConstraint: Constraint?
    private var tabBarItemContainerBottomConstraint: Constraint?
    private var tabBarItemContainerLeadingConstraint: Constraint?
    private var tabBarItemContainerTrailingConstraint: Constraint?
    
    
    // MARK: Delegate
    
    weak var delegate: SOMStickyTabBarDelegate?
    
    
    // MARK: Initialize
    
    init() {
        super.init(frame: .zero)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        for (index, frame) in self.itemFrames.enumerated() {
            // 현재 선택한 좌표가 아이템의 내부이고 선택된 아이템이 아닐 때
            if frame.contains(location), self.selectedIndex != index {
                // 선택할 수 있는 상태일 때
                if self.delegate?.tabBar(self, shouldSelectTabAt: index) ?? true {
                    self.didSelectTabBarItem(index)
                }
            }
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.tabBarItemContainer)
        self.tabBarItemContainer.snp.makeConstraints {
            self.tabBarItemContainerTopConstraint = $0.top.equalToSuperview().offset(self.inset.top).constraint
            self.tabBarItemContainerBottomConstraint = $0.bottom.equalToSuperview().offset(-self.inset.bottom).constraint
            self.tabBarItemContainerLeadingConstraint = $0.leading.equalToSuperview().offset(self.inset.left).constraint
            self.tabBarItemContainerTrailingConstraint = $0.trailing.lessThanOrEqualToSuperview().offset(-self.inset.right).constraint
        }
        
        self.addSubview(self.bottomSeperator)
        self.bottomSeperator.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func refreshConstraints() {
        
        self.tabBarItemContainer.spacing = self.spacing
        
        self.tabBarItemContainerTopConstraint?.deactivate()
        self.tabBarItemContainerBottomConstraint?.deactivate()
        self.tabBarItemContainerLeadingConstraint?.deactivate()
        self.tabBarItemContainerTrailingConstraint?.deactivate()
        self.tabBarItemContainer.snp.makeConstraints {
            self.tabBarItemContainerTopConstraint = $0.top.equalToSuperview().offset(self.inset.top).constraint
            self.tabBarItemContainerBottomConstraint = $0.bottom.equalToSuperview().offset(-self.inset.bottom).constraint
            self.tabBarItemContainerLeadingConstraint = $0.leading.equalToSuperview().offset(self.inset.left).constraint
            self.tabBarItemContainerTrailingConstraint = $0.trailing.lessThanOrEqualToSuperview().offset(-self.inset.right).constraint
        }
    }
    
    private func setTabBarItems(_ items: [String]) {
        
        items.enumerated().forEach { index, title in
            
            let item = SOMStickyTabBarItem(title: title)
            item.updateState(
                color: index == 0 ? Constants.selectedColor : Constants.unSelectedColor,
                hasIndicator: index == 0
            )
            
            self.tabBarItemContainer.addArrangedSubview(item)
        }
    }
    
    
    // MARK: Public func
    
    func didSelectTabBarItem(_ index: Int) {
        
        self.tabBarItemContainer.arrangedSubviews.enumerated().forEach {
            let selectedItem = $1 as? SOMStickyTabBarItem
            selectedItem?.updateState(
                color: $0 == index ? Constants.selectedColor : Constants.unSelectedColor,
                hasIndicator: $0 == index
            )
        }
        
        self.previousIndex = self.selectedIndex
        self.selectedIndex = index
        self.delegate?.tabBar(self, didSelectTabAt: index)
    }
}
