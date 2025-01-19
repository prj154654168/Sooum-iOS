//
//  TermsOfServiceCellView.swift
//  SOOUM
//
//  Created by 오현식 on 1/18/25.
//

import UIKit

import SnapKit
import Then


class TermsOfServiceCellView: UIView {
    
    
    // MARK: Views
    
    private let checkBoxImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.checkBox)))
        $0.tintColor = .som.gray500
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.gray500
        $0.typography = .som.body1WithRegular
    }
    
    let nextButton = SOMButton().then {
        $0.image = .init(.icon(.outlined(.next)))
        $0.foregroundColor = .som.gray800
    }
    
    let backgroundButton = UIButton()
    
    
    // MARK: Initalization
    
    convenience init(title: String) {
        self.init(frame: .zero)
        
        self.titleLabel.text = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(44)
        }
        
        self.addSubview(self.checkBoxImageView)
        self.checkBoxImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(36)
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.checkBoxImageView.snp.trailing).offset(6)
        }
        
        self.addSubview(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.top.equalTo(self.checkBoxImageView.snp.top)
            $0.bottom.equalTo(self.checkBoxImageView.snp.bottom)
            $0.leading.equalTo(self.checkBoxImageView.snp.leading)
            $0.trailing.equalTo(self.titleLabel.snp.trailing)
        }
        
        self.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
            $0.leading.equalTo(self.titleLabel.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().offset(-30)
            $0.size.equalTo(32)
        }
    }
    
    
    // MARK: Public func
    
    func updateState(_ state: Bool, animated: Bool = true) {
        
        let animationDuration: TimeInterval = animated ? 0.25 : 0
        
        UIView.animate(withDuration: animationDuration) {
            self.checkBoxImageView.image = state ? .init(.icon(.filled(.checkBox))) : .init(.icon(.outlined(.checkBox)))
            self.checkBoxImageView.tintColor = state ? .som.p300 : .som.gray600
            
            self.titleLabel.textColor = state ? .som.p300 : .som.gray600
            
            self.nextButton.foregroundColor = state ? .som.p300 : .som.gray600
        }
    }
}
