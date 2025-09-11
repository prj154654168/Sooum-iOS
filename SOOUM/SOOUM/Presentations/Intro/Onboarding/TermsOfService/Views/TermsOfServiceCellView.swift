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
        $0.image = .init(.icon(.v2(.outlined(.check))))
        $0.tintColor = .som.v2.gray200
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.subtitle1
    }
    
    let nextButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.right))))
        $0.foregroundColor = .som.v2.gray500
    }
    
    let backgroundButton = SOMButton()
    
    
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
            $0.height.equalTo(48)
        }
        
        self.addSubview(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.addSubview(self.checkBoxImageView)
        self.checkBoxImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.checkBoxImageView.snp.trailing).offset(8)
        }
        
        self.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
            $0.leading.equalTo(self.titleLabel.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(32)
        }
    }
    
    
    // MARK: Public func
    
    func updateState(_ state: Bool, animated: Bool = true) {
        
        let animationDuration: TimeInterval = animated ? 0.25 : 0
        
        UIView.animate(withDuration: animationDuration) {
            self.checkBoxImageView.tintColor = state ? .som.v2.pDark : .som.v2.gray200
        }
    }
}
