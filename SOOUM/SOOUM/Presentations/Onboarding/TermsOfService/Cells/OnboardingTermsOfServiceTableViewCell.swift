//
//  OnboardingTermsOfServiceTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 11/6/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class OnboardingTermsOfServiceTableViewCell: UITableViewCell {
    
    let checkBoxImageView = UIImageView().then {
        $0.image = .checkboxOutlined
        $0.contentMode = .scaleAspectFill
    }
    
    let titleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 16,
                weight: .medium
            ),
            lineHeight: 24,
            letterSpacing: 0
        )
        $0.textColor = .som.gray02
        $0.text = "[필수] 서비스 이용약관"
    }
    
    let nextImageView = UIImageView().then {
        $0.image = .next
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .som.gray02
    }
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setupConstraint
    private func setupConstraint() {
        contentView.addSubview(checkBoxImageView)
        checkBoxImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(11)
            $0.bottom.equalToSuperview().offset(-11)
            $0.size.equalTo(24)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkBoxImageView.snp.trailing).offset(16)
            $0.top.equalToSuperview().offset(11)
            $0.bottom.equalToSuperview().offset(-11)
        }
        
        contentView.addSubview(nextImageView)
        nextImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(11)
            $0.bottom.equalToSuperview().offset(-11)
            $0.size.equalTo(24)
        }
    }
}
