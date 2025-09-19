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
    
    let moveButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.right))))
        $0.foregroundColor = .som.v2.gray500
    }
    
    let backgroundButton = SOMButton().then {
        $0.backgroundColor = .som.v2.white
    }
    
    
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
        
        let container = UIView()
        self.addSubview(container)
        container.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
        
        container.addSubview(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.addSubview(self.checkBoxImageView)
        self.checkBoxImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(24)
        }
        
        container.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.checkBoxImageView.snp.trailing).offset(8)
        }
        
        container.addSubview(self.moveButton)
        self.moveButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.titleLabel.snp.trailing).offset(12)
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
