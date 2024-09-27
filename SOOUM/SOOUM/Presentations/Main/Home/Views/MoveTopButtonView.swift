//
//  MoveTopButtonView.swift
//  SOOUM
//
//  Created by 오현식 on 9/25/24.
//

import UIKit

import SnapKit
import Then


class MoveTopButtonView: UIView {
    
    enum Text {
        static let title: String = "맨위로 이동"
    }
    
    static let height: CGFloat = 40
    
    let backgroundButton = UIButton(configuration: .plain())
    
    private let titleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.gray01
        $0.typography = .init(
            fontContainer: Pretendard(size: 14, weight: .bold),
            lineHeight: 17,
            letterSpacing: -0.56
        )
    }
    
    private let imageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.arrowTop)))
        $0.tintColor = .som.gray01
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let backgroundView = UIView().then {
            $0.backgroundColor = .som.white
            $0.layer.cornerRadius = 40 * 0.5
            $0.layer.borderColor = UIColor.som.gray02.cgColor
            $0.layer.borderWidth = 1
        }
        
        backgroundView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(24)
        }
        
        backgroundView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.titleLabel.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(24)
        }
        
        backgroundView.addSubview(self.backgroundButton)
        self.bringSubviewToFront(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.addSubviews(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
