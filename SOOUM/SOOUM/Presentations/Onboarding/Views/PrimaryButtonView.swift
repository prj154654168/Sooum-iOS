//
//  PrimaryButtonView.swift
//  SOOUM
//
//  Created by JDeoks on 11/6/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

/// 하단 확인 버튼
class PrimaryButtonView: UIView {
    
    var isEnabled: Bool = true
    
    let label = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 16,
                weight: .regular
            ),
            lineHeight: 24,
            letterSpacing: 0
        )
        $0.textColor = .som.black
        $0.text = "다음"
    }
    
    // MARK: - init
    convenience init(isEnabled: Bool) {
        self.init(frame: .zero)
        self.isEnabled = isEnabled
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .som.gray03
        self.layer.cornerRadius = 12
        initConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        self.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        self.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func updateState(state: Bool, animated: Bool = true) {
        self.isEnabled = state
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.backgroundColor = state ? .som.primary : .som.gray03
        }
        UIView.transition(with: label, duration: animated ? 0.2 : 0, options: .transitionCrossDissolve) {
            self.label.textColor = state ? .som.white : .som.black
        }
    }
}
