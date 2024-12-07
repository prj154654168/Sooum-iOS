//
//  TagPreviewCardView.swift
//  SOOUM
//
//  Created by JDeoks on 11/26/24.
//

import UIKit

class TagPreviewCardView: UIView {
    
    /// 배경 이미지
    let rootContainerImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    /// cardTextContentLabel를 감싸는 불투명 컨테이너 뷰
    let cardTextBackgroundView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    /// cardTextContentLabel를 감싸는 블러 컨테이너 뷰
    let cardTextBackgroundBlurView = UIVisualEffectView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: .dark)
        $0.effect = blurEffect
        $0.backgroundColor = .som.dim
        $0.alpha = 0.8
    }
    
    /// 본문 표시 라벨
    let cardTextContentLabel = UILabel().then {
        $0.typography = .som.body3WithBold
        $0.textColor = .som.white
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.text = "본문입니다본문입니다본문입니다본문입니다"
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .som.gray200
        self.layer.cornerRadius = 20
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupConstraints
    private func setupConstraints() {
        self.addSubview(rootContainerImageView)
        rootContainerImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        rootContainerImageView.addSubview(cardTextBackgroundView)
        cardTextBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        rootContainerImageView.addSubview(cardTextBackgroundBlurView)
        cardTextBackgroundBlurView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        rootContainerImageView.addSubview(cardTextContentLabel)
        cardTextContentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(36)
            $0.top.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-36)
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
}
