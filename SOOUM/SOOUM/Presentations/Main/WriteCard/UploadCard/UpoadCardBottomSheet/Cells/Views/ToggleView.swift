//
//  ToggleView.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class ToggleView: UIView {
    
    var toggleState: BehaviorRelay<Bool>?
    
    var disposeBag = DisposeBag()
        
    private let backgroundView = UIView().then {
        $0.backgroundColor = .som.gray400
        $0.layer.cornerRadius = 12
    }
    
    private let toggleCircle = UIView().then {
        $0.backgroundColor = .som.white
        $0.layer.cornerRadius = 10
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
        updateToggleView(toggleState?.value ?? false, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    func setData(toggleState: BehaviorRelay<Bool>) {
        self.toggleState = toggleState
        self.toggleState?
            .subscribe(with: self) { object, toggleState in
                object.updateToggleView(toggleState, animated: false)
            }
        .disposed(by: self.disposeBag)
        
        action()
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
            .subscribe(with: self) { object, _ in
                if let toggleState = object.toggleState {
                    toggleState.accept(!toggleState.value)
                    object.updateToggleView(toggleState.value, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func updateToggleView(_ state: Bool, animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.2 : 0.0,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.toggleCircle.snp.updateConstraints {
                    $0.leading.equalToSuperview().offset(state ? 18 : 2)
                }
                self.layoutIfNeeded()
                self.backgroundView.backgroundColor = state ? .som.p300 : .som.gray400
            },
            completion: nil
        )
    }
}
