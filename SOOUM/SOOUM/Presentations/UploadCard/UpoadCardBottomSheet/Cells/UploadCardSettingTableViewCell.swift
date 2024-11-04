//
//  UploadCardSettingTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

class UploadCardSettingTableViewCell: UITableViewCell {
    
    /// 현재 셀 옵션
    var cellOption: UploadCardBottomSheetViewController.Section.OtherSettings = .timeLimit
    /// 뷰컨으로부터 받은 전체 옵션 상태
    var globalCardOption: BehaviorRelay<[UploadCardBottomSheetViewController.Section.OtherSettings: Bool]>?
    /// 현재 셀 토글 값
    let cellToggleState = BehaviorRelay<Bool>(value: false)
    
    var disposeBag = DisposeBag()
    
    let titleStackContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let titleStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 6
    }
    
    let titleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 16, weight: .medium),
            lineHeight: 16
         )
        $0.textColor = .som.black
        $0.text = "시간 제한"
    }
    
    let descLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 12, weight: .medium),
            lineHeight: 14.4
         )
        $0.textColor = .som.gray02
        $0.text = "태그를 사용할 수 없고, 24시간 뒤 모든 카드가 삭제돼요"
    }
    
    let toggleView = ToggleView()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.autoresizingMask = .flexibleHeight
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        toggleView.prepareForReuse()
    }
    
    // MARK: - setData
    func setData(
        cellOption: UploadCardBottomSheetViewController.Section.OtherSettings,
        globalCardOptionState: BehaviorRelay<[UploadCardBottomSheetViewController.Section.OtherSettings: Bool]>
    ) {
        print("\(type(of: self)) - \(#function)", globalCardOptionState)

        self.cellOption = cellOption
        titleLabel.text = cellOption.title
        descLabel.text = cellOption.description
        self.globalCardOption = globalCardOptionState
        cellToggleState.accept(globalCardOptionState.value[cellOption] ?? false)
        
        bind()
        
        toggleView.setData(toggleState: cellToggleState)
    }
    
    func bind() {
        print("\(type(of: self)) - \(#function)")

        cellToggleState
            .distinctUntilChanged()
            .subscribe(with: self) { object, state in
                print(self.cellToggleState)
                if var updatedOptions = self.globalCardOption?.value {
                    updatedOptions[self.cellOption] = self.cellToggleState.value
                    self.globalCardOption?.accept(updatedOptions)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - setupConstraint
    private func setupConstraint() {
        contentView.addSubview(toggleView)
        toggleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(32)
            $0.width.equalTo(48)
        }
        
        contentView.addSubview(titleStackContainerView)
        titleStackContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(36)
            $0.bottom.equalToSuperview()
        }
        
        titleStackContainerView.addSubview(titleStack)
        titleStack.addArrangedSubviews(titleLabel, descLabel)
        titleStack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
}
