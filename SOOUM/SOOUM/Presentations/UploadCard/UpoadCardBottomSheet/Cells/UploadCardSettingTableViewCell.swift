//
//  UploadCardSettingTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

class UploadCardSettingTableViewCell: UITableViewCell {
    
    let titleStackContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let titleStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 6
    }
    
    let titleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(size: 16, weight: .medium),
            lineHeight: 16
         )
        $0.textColor = .som.black
        $0.text = "시간 제한"
    }
    
    let descLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(size: 12, weight: .medium),
            lineHeight: 14.4
         )
        $0.textColor = .som.gray02
        $0.text = "태그를 사용할 수 없고, 24시간 뒤 모든 카드가 삭제돼요"
    }
    
    let togglebView = ToggleView()
    
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
    
    func setData(settingOption: UploadCardBottomSheetViewController.Section.OtherSettings, state: Bool) {
        titleLabel.text = settingOption.title
        descLabel.text = settingOption.description
        togglebView.updateToggle(state, animated: false)
    }

    // MARK: - setupConstraint
    private func setupConstraint() {
        contentView.addSubview(togglebView)
        togglebView.snp.makeConstraints {
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
