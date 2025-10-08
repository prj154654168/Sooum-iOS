//
//  SOMSwipableTabBar.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/25.
//

import UIKit

import SnapKit
import Then


class SOMSwipableTabBar: UIView {
    
    enum Constants {
        static let height: CGFloat = 56
        
        static let selectedTypo: Typography = Typography.som.v2.subtitle3
        static let unSelectedTypo: Typography = Typography.som.v2.body1
        
        static let selectedColor: UIColor = UIColor.som.v2.gray600
        static let unSelectedColor: UIColor = UIColor.som.v2.gray400
        
        static let selectedBackgroundColor: UIColor = UIColor.som.v2.gray100
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
    
    
    // MARK: Variables
    
    var inset: UIEdgeInsets = .init(top: 9.5, left: 16, bottom: 9.5, right: 16) {
        didSet {
            self.refreshConstraints()
        }
    }
    
    var spacing: CGFloat = 0 {
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
    var itemFrames: [CGRect] {
        let itemWidths: [CGFloat] = self.items.enumerated().map { index, item in
            let typography: Typography = self.selectedIndex == index ? Constants.selectedTypo : Constants.unSelectedTypo
            /// 실제 텍스트 가로 길이 + 패딩
            return (item as NSString).size(withAttributes: [.font: typography.font]).width + 10 * 2
        }
        
        var itemFrames: [CGRect] = []
        var currentX: CGFloat = self.inset.left
        for itemWidth in itemWidths {
            let itemFrame = CGRect(x: currentX, y: 0, width: itemWidth, height: self.bounds.height)
            itemFrames.append(itemFrame)
            currentX += itemWidth
        }
        
        return itemFrames
    }
    
    var previousIndex: Int = 0
    var selectedIndex: Int = 0
    
    
    // MARK: Constraint
    
    private var tabBarItemContainerTopConstraint: Constraint?
    private var tabBarItemContainerBottomConstraint: Constraint?
    private var tabBarItemContainerLeadingConstraint: Constraint?
    private var tabBarItemContainerTrailingConstraint: Constraint?
    
    
    // MARK: Delegate
    
    weak var delegate: SOMSwipableTabBarDelegate?
    
    
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
        
        self.snp.makeConstraints {
            $0.height.equalTo(Constants.height)
        }
        
        self.addSubview(self.tabBarItemContainer)
        self.tabBarItemContainer.snp.makeConstraints {
            self.tabBarItemContainerTopConstraint = $0.top.equalToSuperview().offset(self.inset.top).constraint
            self.tabBarItemContainerBottomConstraint = $0.bottom.equalToSuperview().offset(-self.inset.bottom).constraint
            self.tabBarItemContainerLeadingConstraint = $0.leading.equalToSuperview().offset(self.inset.left).constraint
            self.tabBarItemContainerTrailingConstraint = $0.trailing.lessThanOrEqualToSuperview().offset(-self.inset.right).constraint
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
            
            let item = SOMSwipableTabBarItem(title: title)
            item.updateState(
                color: index == 0 ? Constants.selectedColor : Constants.unSelectedColor,
                typo: index == 0 ? Constants.selectedTypo : Constants.unSelectedTypo,
                backgroundColor: index == 0 ? Constants.selectedBackgroundColor : nil
            )
            
            self.tabBarItemContainer.addArrangedSubview(item)
        }
    }
    
    
    // MARK: Public func
    
    func didSelectTabBarItem(_ index: Int, onlyUpdateApperance: Bool = false) {
        
        self.tabBarItemContainer.arrangedSubviews.enumerated().forEach {
            let selectedItem = $1 as? SOMSwipableTabBarItem
            selectedItem?.updateState(
                color: index == $0 ? Constants.selectedColor : Constants.unSelectedColor,
                typo: index == $0 ? Constants.selectedTypo : Constants.unSelectedTypo,
                backgroundColor: index == $0 ? Constants.selectedBackgroundColor : nil
            )
        }
        
        self.previousIndex = self.selectedIndex
        self.selectedIndex = index
        if onlyUpdateApperance == false {
            self.delegate?.tabBar(self, didSelectTabAt: index)
        }
    }
}
