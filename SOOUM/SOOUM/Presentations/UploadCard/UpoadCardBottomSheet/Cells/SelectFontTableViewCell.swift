//
//  SelectFontTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

class SelectFontTableViewCell: UITableViewCell {

    let titleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(size: 16, weight: .medium),
            lineHeight: 16
         )
        $0.textAlignment = .center
        $0.textColor = .som.black
        $0.text = "글씨체"
    }
    
    let buttonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    let gothicButtonLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(size: 16, weight: .medium),
            lineHeight: 16
         )
        $0.textAlignment = .center
        $0.textColor = .som.white
        $0.backgroundColor = .som.primary
        $0.text = "고딕체"
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }

    let handwritingButtonLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(size: 16, weight: .medium),
            lineHeight: 16
         )
        $0.textAlignment = .center
        $0.textColor = .som.gray01
        $0.backgroundColor = .som.gray04
        $0.text = "손글씨체"
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    let seperatorView = UIView().then {
        $0.backgroundColor = .som.gray04
    }
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setupConstraint
    private func setupConstraint() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        contentView.addSubview(buttonStack)
        buttonStack.addArrangedSubviews(gothicButtonLabel, handwritingButtonLabel)
        buttonStack.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-24)
        }
        
        gothicButtonLabel.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        handwritingButtonLabel.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        contentView.addSubview(seperatorView)
        seperatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(4)
        }
    }
}
