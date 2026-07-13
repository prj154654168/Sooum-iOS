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

    private let voteGuideMessage = "투표를 추가해 사람들의 의견을 물어보세요!"
    
    private lazy var voteGuideBubbleView = SOMMessageBubbleView(isDeletable: true).then {
        $0.message = self.voteGuideMessage
        $0.isHidden = true
    }
    
    
    // MARK: Variables
    
    let optionTapped = PublishRelay<SelectOptionItem.OptionType>()
    let disabledOptionTapped = PublishRelay<SelectOptionItem.OptionType>()
    let voteGuideDeleteButtonDidTap = PublishRelay<Void>()
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
    private weak var voteItem: SelectOptionItem?
    private var shouldShowVoteGuide: Bool = false
    private var voteGuideLastLayoutFrame: CGRect = .zero
    private var voteGuideLastLayoutWidth: CGFloat = 0
    
    
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

        self.addSubview(self.voteGuideBubbleView)
        self.voteGuideBubbleView.snp.makeConstraints {
            $0.width.equalTo(158)
            $0.height.equalTo(29)
        }

        self.voteGuideBubbleView.deleteButtonDidTap
            .subscribe(with: self) { object, _ in
                object.hideVoteGuide()
                object.voteGuideDeleteButtonDidTap.accept(())
            }
            .disposed(by: self.disposeBag)
    }
    
    private func setupItems(_ items: [SelectOptionItem.OptionType]) {
        
        items.forEach { type in
            
            let item = SelectOptionItem(type: type)
            self.container.addArrangedSubview(item)

            if type == .vote {
                self.voteItem = item
            }
            
            item.rx.tapGesture()
                .when(.recognized)
                .subscribe(with: self) { object, _ in
                    guard item.isEnabled else {
                        object.disabledOptionTapped.accept(type)
                        return
                    }
                    
                    let hasOption = object.selectOptions.contains(where: { $0 == type })
                    
                    switch type {
                    case .vote:
                        if hasOption == false { object.selectOptions += [type] }
                    default:
                        object.selectOptions = hasOption ?
                            object.selectOptions.filter { $0 != type } :
                            object.selectOptions + [type]
                    }
                    
                    object.optionTapped.accept(type)
                }
                .disposed(by: self.disposeBag)
        }

        self.setNeedsLayout()
    }
    
    func setOptionEnabled(_ isEnabled: Bool, for type: SelectOptionItem.OptionType) {
        guard let item = self.container.arrangedSubviews
            .compactMap({ $0 as? SelectOptionItem })
            .first(where: { $0.optionType == type })
        else { return }
        
        item.isEnabled = isEnabled
    }
    
    func showVoteGuide() {
        self.shouldShowVoteGuide = true
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func hideVoteGuide() {
        self.shouldShowVoteGuide = false
        self.voteGuideBubbleView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutVoteGuideIfNeeded()
    }
    
    private func layoutVoteGuideIfNeeded() {
        guard self.shouldShowVoteGuide, let voteItem = self.voteItem else {
            self.voteGuideBubbleView.isHidden = true
            return
        }

        let messageWidth = (self.voteGuideMessage as NSString).size(
            withAttributes: [.font: Typography.som.v2.caption1.font]
        ).width
        let bubbleWidth = ceil(messageWidth) + 10 + 2 + 16 + 8
        let voteItemFrame = voteItem.frame

        guard self.voteGuideBubbleView.isHidden
            || self.voteGuideLastLayoutFrame != voteItemFrame
            || self.voteGuideLastLayoutWidth != bubbleWidth
        else { return }
        
        self.voteGuideBubbleView.isHidden = false
        self.bringSubviewToFront(self.voteGuideBubbleView)
        self.voteGuideBubbleView.snp.remakeConstraints {
            $0.centerX.equalTo(voteItem.snp.centerX)
            $0.bottom.equalTo(voteItem.snp.top).offset(-4)
            $0.width.equalTo(bubbleWidth)
            $0.height.equalTo(29)
        }
        self.voteGuideLastLayoutFrame = voteItemFrame
        self.voteGuideLastLayoutWidth = bubbleWidth
    }
}
