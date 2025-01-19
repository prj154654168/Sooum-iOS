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
        static let title: String = "약관 전체 동의"
    }
    
    
    // MARK: Views
    
    private let checkImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.check)))
        $0.tintColor = .som.gray600
    }
    
    private let titleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.gray600
        $0.typography = .som.head2WithRegular
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
        
        self.layer.borderColor = UIColor.som.gray300.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 12
        
        self.addSubview(self.checkImageView)
        self.checkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.checkImageView.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    
    // MARK: Public func
    
    func updateState(_ state: Bool, animated: Bool = true) {
        
        let animationDuration: TimeInterval = animated ? 0.25 : 0
        
        UIView.animate(withDuration: animationDuration) {
            self.layer.borderColor = state ? UIColor.som.p300.cgColor : UIColor.som.gray300.cgColor
            self.checkImageView.tintColor = state ? .som.p300 : .som.gray600
            self.titleLabel.textColor = state ? .som.p300 : .som.gray600
        }
    }
}
