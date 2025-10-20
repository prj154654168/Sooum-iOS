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
import RxGesture
import RxSwift

class SelectOptionsView: UIView {
    
    
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
    
    var selectedOptions = BehaviorRelay<[SelectOptionItem.OptionType]?>(value: nil)
    var selectOptions: [SelectOptionItem.OptionType] = [] {
        didSet {
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
    
    private var disposeBag = DisposeBag()
    
    
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
            
            item.rx.tapGesture()
                .when(.recognized)
                .subscribe(with: self) { object, _ in
                    let hasOption = object.selectOptions.contains(where: { $0 == type })
                    object.selectOptions = hasOption ?
                        object.selectOptions.filter { $0 != type } :
                        object.selectOptions + [type]
                }
                .disposed(by: self.disposeBag)
        }
    }
}
