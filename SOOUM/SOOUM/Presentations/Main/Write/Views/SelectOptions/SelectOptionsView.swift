//
//  SelectOptionView.swift
//  SOOUM
//
//  Created by 오현식 on 10/11/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa

final class SelectOptionsView: UIView {
    
    enum Text {
        static let voteGuideMessage = "투표를 추가해 사람들의 의견을 물어보세요!"
    }
    
    
    // MARK: Views
    
    private let seperator = UIView().then {
        $0.backgroundColor = .som.v2.gray200
    }
    
    private let container = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 6
    }
    // MARK: Variables
    
    let optionTapped = PublishRelay<SelectOptionItem.OptionType>()
    let disabledOptionTapped = PublishRelay<SelectOptionItem.OptionType>()
    var selectedOptions = BehaviorRelay<[SelectOptionItem.OptionType]?>(value: nil)
    var selectOptions: [SelectOptionItem.OptionType] = [] {
        didSet {
            guard oldValue != self.selectOptions else { return }
            
            self.container.subviews.forEach { item in
                guard let item = item as? SelectOptionItem else { return }
                
                let hasOption = self.selectOptions.contains(where: { $0 == item.optionType })
                item.isSelected = hasOption
            }
            
            self.selectedOptions.accept(self.selectOptions)
        }
    }
    
    var items: [SelectOptionItem.OptionType] = [] {
        didSet {
            if self.items.isEmpty == false {
                self.setupItems(self.items)
            }
        }
    }
    
    private weak var voteItem: SelectOptionItem?
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.seperator)
        self.seperator.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    private func setupItems(_ items: [SelectOptionItem.OptionType]) {
        
        items.forEach { type in
            
            let item = SelectOptionItem(type: type)
            self.container.addArrangedSubview(item)

            if type == .vote {
                self.voteItem = item
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapOptionItem(_:)))
            item.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc
    private func didTapOptionItem(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let item = gestureRecognizer.view as? SelectOptionItem,
              let type = item.optionType
        else { return }
        
        guard item.isEnabled else {
            self.disabledOptionTapped.accept(type)
            return
        }
        
        let hasOption = self.selectOptions.contains(where: { $0 == type })
        
        switch type {
        case .vote:
            if hasOption == false { self.selectOptions += [type] }
        default:
            self.selectOptions = hasOption ?
                self.selectOptions.filter { $0 != type } :
                self.selectOptions + [type]
        }
        
        self.optionTapped.accept(type)
    }
    
    func setOptionEnabled(_ isEnabled: Bool, for type: SelectOptionItem.OptionType) {
        guard let item = self.container.arrangedSubviews
            .compactMap({ $0 as? SelectOptionItem })
            .first(where: { $0.optionType == type })
        else { return }
        
        item.isEnabled = isEnabled
    }
    
    func voteGuideAnchorFrame(in view: UIView) -> CGRect? {
        guard let voteItem else { return nil }
        
        return voteItem.convert(voteItem.bounds, to: view)
    }
}
