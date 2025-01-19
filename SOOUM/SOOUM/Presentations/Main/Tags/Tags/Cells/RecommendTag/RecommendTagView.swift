//
//  RecommendTagView.swift
//  SOOUM
//
//  Created by JDeoks on 11/26/24.
//

import UIKit

class RecommendTagView: UIView {
    
    let tagNameLabel = UILabel().then {
        $0.typography = .som.body3WithBold
        $0.text = "#태그이름"
        $0.textColor = .som.gray800
    }
    
    let tagsCountLabel = UILabel().then {
        $0.typography = .som.body3WithBold
        $0.text = "999"
        $0.textColor = .som.gray500
    }
    
    let moreButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
    }
    
    let moreButtonLabel = UILabel().then {
        $0.typography = .som.body3WithBold
        $0.text = "더보기"
        $0.textColor = .som.blue300
    }
    
    let moreImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.next)))
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .som.blue300
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.som.gray200.cgColor
        self.layer.borderWidth = 1
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraint() {
        self.addSubview(tagNameLabel)
        tagNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        self.addSubview(tagsCountLabel)
        tagsCountLabel.snp.makeConstraints {
            $0.leading.equalTo(self.tagNameLabel.snp.trailing).offset(2)
            $0.centerY.equalToSuperview()
        }
        
        self.addSubview(moreButtonStackView)
        moreButtonStackView.addArrangedSubviews(moreButtonLabel, moreImageView)
        moreButtonStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }
    }
}
