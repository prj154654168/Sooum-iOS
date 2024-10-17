//
//  ToggleView.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import RxGesture
import RxSwift

import SnapKit
import Then

class ToggleView: UIView {
    
    let disposeBag = DisposeBag()
    
    private var isOn: Bool = false
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .som.gray04
        $0.layer.cornerRadius = 12
    }
    
    private let toggleCircle = UIView().then {
        $0.backgroundColor = .som.white
        $0.layer.cornerRadius = 10
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
        action()
        updateToggle(isOn, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraint() {
        self.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(24)
            $0.width.equalTo(40)
        }
        
        backgroundView.addSubview(toggleCircle)
        toggleCircle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
            $0.leading.equalToSuperview().offset(2)
        }
    }
    
    private func action() {
        self.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                self.isOn.toggle()
                self.updateToggle(self.isOn, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func updateToggle(_ state: Bool, animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.2 : 0.0,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.toggleCircle.snp.updateConstraints {
                    $0.leading.equalToSuperview().offset(state ? 18 : 2)
                }
                self.layoutIfNeeded()
                self.backgroundView.backgroundColor = state ? .som.primary : .som.gray04
            }, 
            completion: nil
        )
    }
}
