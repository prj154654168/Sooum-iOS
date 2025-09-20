//
//  TermsOfServiceAgreeButtonView.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import UIKit

import SnapKit
import Then


class TermsOfServiceAgreeButtonView: UIView {
    
    enum Text {
        static let title: String = "전체 동의하기"
    }
    
    
    // MARK: Views
    
    private let checkImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.check))))
        $0.tintColor = .som.v2.gray400
    }
    
    private let titleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.v2.gray600
        $0.typography = .som.v2.title1
    }
    
    let backgroundButton = SOMButton().then {
        $0.backgroundColor = .som.v2.gray100
    }
    
    
    // MARK: Initalization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        let container = UIView()
        self.addSubview(container)
        container.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
        
        container.addSubview(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.addSubview(self.checkImageView)
        self.checkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(24)
        }
        
        container.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.checkImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    
    // MARK: Public func
    
    func updateState(_ state: Bool, animated: Bool = true) {
        
        let animationDuration: TimeInterval = animated ? 0.25 : 0
        
        UIView.animate(withDuration: animationDuration) {
            self.checkImageView.tintColor = state ? .som.v2.pDark : .som.v2.gray400
        }
    }
}
