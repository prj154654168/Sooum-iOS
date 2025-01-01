//
//  SOMSwipeTabBar.swift
//  SOOUM
//
//  Created by 오현식 on 12/21/24.
//

import UIKit

import SnapKit
import Then


class SOMSwipeTabBar: UIView {
    
    enum Height {
        static let mainHome: CGFloat = 40
        static let notification: CGFloat = 38
    }
    
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
        $0.backgroundColor = .som.gray200
    }
    
    private let selectedIndicator = UIView().then {
        $0.backgroundColor = .som.p300
    }
    
    var inset: UIEdgeInsets = .init(top: 4, left: 12, bottom: 10, right: 0) {
        didSet {
            self.refreshConstraints()
        }
    }
    
    var spacing: CGFloat = 2 {
        didSet {
            self.refreshConstraints()
        }
    }
    
    var seperatorHeight: CGFloat = 1 {
        didSet {
            self.refreshConstraints()
        }
    }
    
    var seperatorColor: UIColor = .som.gray200 {
        didSet {
            self.bottomSeperator.backgroundColor = self.seperatorColor
        }
    }
    
    private var tabBarItemContainerTopConstraint: Constraint?
    private var tabBarItemContainerBottomConstraint: Constraint?
    private var tabBarItemContainerLeadingConstraint: Constraint?
    
    private var bottomSeperatorHeightConstraint: Constraint?
    
    private var selectedIndicatorLeadingConstraint: Constraint?
    private var selectedIndicatorWidthConstraint: Constraint?
    
    private var itemAlignment: ItemAlignment
    
    private var defaultTypo: Typography
    private var selectedTypo: Typography
    
    private var defaultColor: UIColor
    private var selectedColor: UIColor
    
    var items: [String] = [] {
        didSet {
            if self.items.isEmpty == false {
                self.setTabBarItems(self.items)
            }
        }
    }
    
    var itemWidth: CGFloat {
        let width = self.itemAlignment == .fill ? UIScreen.main.bounds.width / CGFloat(self.items.count) : 53
        return width
    }
    
    weak var delegate: SOMSwipeTabBarDelegate?
    
    var previousIndex: Int = 0
    var selectedIndex: Int = 0
    
    init(alignment: ItemAlignment) {
        self.itemAlignment = alignment
        self.selectedIndicator.isHidden = alignment == .left
        
        self.defaultTypo = alignment == .fill ? .som.body2WithRegular : .som.body2WithBold
        self.selectedTypo = .som.body2WithBold
        
        self.defaultColor = alignment == .fill ? .som.gray400 : .som.gray500
        self.selectedColor = alignment == .fill ? .som.p300 : .som.black
        
        super.init(frame: .zero)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.addSubview(self.tabBarItemContainer)
        self.tabBarItemContainer.snp.makeConstraints {
            self.tabBarItemContainerTopConstraint = $0.top.equalToSuperview().offset(self.inset.top).constraint
            self.tabBarItemContainerBottomConstraint = $0.bottom.equalToSuperview().offset(-self.inset.bottom).constraint
            self.tabBarItemContainerLeadingConstraint = $0.leading.equalToSuperview().offset(self.inset.left).constraint
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        self.addSubview(self.bottomSeperator)
        self.bottomSeperator.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            self.bottomSeperatorHeightConstraint = $0.height.equalTo(1).constraint
        }
        
        self.addSubview(self.selectedIndicator)
        self.selectedIndicator.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            self.selectedIndicatorLeadingConstraint = $0.leading.equalToSuperview().constraint
            $0.height.equalTo(1.6)
        }
    }
    
    private func refreshConstraints() {
        
        self.tabBarItemContainer.spacing = self.spacing
        
        self.tabBarItemContainerTopConstraint?.deactivate()
        self.tabBarItemContainerBottomConstraint?.deactivate()
        self.tabBarItemContainerLeadingConstraint?.deactivate()
        self.tabBarItemContainer.snp.makeConstraints {
            self.tabBarItemContainerTopConstraint = $0.top.equalToSuperview().offset(self.inset.top).constraint
            self.tabBarItemContainerBottomConstraint = $0.bottom.equalToSuperview().offset(-self.inset.bottom).constraint
            self.tabBarItemContainerLeadingConstraint = $0.leading.equalToSuperview().offset(self.inset.left).constraint
        }
        
        self.bottomSeperatorHeightConstraint?.deactivate()
        self.bottomSeperator.snp.makeConstraints {
            self.bottomSeperatorHeightConstraint = $0.height.equalTo(self.seperatorHeight).constraint
        }
    }
    
    private func setTabBarItems(_ items: [String]) {
        
        items.enumerated().forEach { index, title in
            
            let item = SOMSwipeTabBarItem(title: title)
            item.updateState(
                color: index == 0 ? self.selectedColor : self.defaultColor,
                typo: index == 0 ? self.selectedTypo : self.defaultTypo,
                with: 0
            )
            
            item.snp.makeConstraints {
                $0.width.equalTo(self.itemWidth)
            }
            self.tabBarItemContainer.addArrangedSubview(item)
            
            if self.itemAlignment == .fill {
                
                self.selectedIndicatorWidthConstraint?.deactivate()
                self.selectedIndicator.snp.makeConstraints {
                    self.selectedIndicatorWidthConstraint = $0.width.equalTo(self.itemWidth).constraint
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touchArea = touches.first?.location(in: self),
            self.tabBarItemContainer.frame.contains(touchArea) else { return }
        
        let convertTouchAreaInContainer = convert(touchArea, to: self.tabBarItemContainer).x
        let index = Int(floor(convertTouchAreaInContainer / self.itemWidth))
        
        if self.selectedIndex != index,
           self.delegate?.tabBar(self, shouldSelectTabAt: index) ?? true {
            self.didSelectTabBarItem(index)
        }
    }
    
    func didSelectTabBarItem(_ index: Int, animated: Bool = true) {
        
        let animationDuration: TimeInterval = animated ? 0.25 : 0
        
        self.tabBarItemContainer.arrangedSubviews.enumerated().forEach {
            let selectedItem = $1 as? SOMSwipeTabBarItem
            selectedItem?.updateState(
                color: $0 == index ? self.selectedColor : self.defaultColor,
                typo: $0 == index ? self.selectedTypo : self.defaultTypo,
                with: $0 == index ? animationDuration : 0
            )
        }
        
        if self.itemAlignment == .fill {
            let indicatorLeadingOffset: CGFloat = self.itemWidth * CGFloat(index)
            
            self.selectedIndicatorLeadingConstraint?.deactivate()
            self.selectedIndicator.snp.makeConstraints {
                self.selectedIndicatorLeadingConstraint = $0.leading.equalToSuperview().offset(indicatorLeadingOffset).constraint
            }
            
            UIView.animate(withDuration: animationDuration) {
                self.layoutIfNeeded()
            }
        }
        
        self.previousIndex = self.selectedIndex
        self.selectedIndex = index
        self.delegate?.tabBar(self, didSelectTabAt: index)
    }
}

extension SOMSwipeTabBar {
    
    enum ItemAlignment {
        case left
        case fill
    }
}
