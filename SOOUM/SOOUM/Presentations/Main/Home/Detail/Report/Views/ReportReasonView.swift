//
//  ReportReasonView.swift
//  SOOUM
//
//  Created by JDeoks on 10/14/24.
//

import UIKit

import SnapKit
import Then

class ReportReasonView: UIView {
    
    let rootContainerView = UIView().then {
        $0.backgroundColor = .som.white
        $0.layer.borderColor = UIColor.som.gray04.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 12
    }
    
    let toggleView = UIImageView().then {
        $0.image = .init(systemName: "Circle")
    }
    
    let titleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 16,
                weight: .regular
            ),
            lineHeight: 22,
            letterSpacing: 0
        )
        $0.textColor = .som.black
    }
    
    let descLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 12,
                weight: .regular
            ),
            lineHeight: 17,
            letterSpacing: 0
        )
        $0.textColor = .som.gray02
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initUI
    private func initUI() {
        addSubviews()
        initConstraint()
    }
    
    // MARK: - addSubviews
    private func addSubviews() {
        self.addSubviews(rootContainerView)
        rootContainerView.addSubviews(toggleView, titleLabel, descLabel)
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        rootContainerView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview()
        }
        
        toggleView.snp.makeConstraints {
            $0.size.equalTo(22)
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(10)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.leading.equalTo(toggleView.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(10)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
