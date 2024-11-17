//
//  OnboardingTermsOfServiceTableViewCell.swift
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

class OnboardingTermsOfServiceTableViewCell: UITableViewCell {
    
    /// 전체 선택 상황
    var agreementStatus: BehaviorRelay<[TermsOfService: Bool]>?
    /// 현재 셀의 항목
    var term: TermsOfService = .termsOfService
    
    var disposeBag = DisposeBag()
    
    let checkBoxImageView = UIImageView().then {
        $0.image = .checkboxOutlined
        $0.contentMode = .scaleAspectFill
    }
    
    let titleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 16,
                weight: .regular
            ),
            lineHeight: 24,
            letterSpacing: 0
        )
        $0.textColor = .som.gray500
        $0.text = ""
    }
    
    let nextImageView = UIImageView().then {
        $0.image = .next
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .som.gray500
    }
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func setData(
//        state: BehaviorRelay<[OnboardingTermsOfServiceViewController.TermsOfService: Bool]>,
//        term: OnboardingTermsOfServiceViewController.TermsOfService
//    ) {
//        disposeBag = DisposeBag()
//
//        agreementStatus = state
//        self.term = term
//        titleLabel.text = term.text
//        updateState(isOn: state.value[term] ?? false)
//        
//        agreementStatus?.subscribe(with: self) { object, state in
//            object.updateState(isOn: state[term] ?? false, animated: true)
//        }
//        .disposed(by: self.disposeBag)
//    }
    
    func setData(
        state: Bool,
        term: TermsOfService
    ) {
        self.term = term
        titleLabel.text = term.text
        updateState(isOn: state)
    }

    // MARK: - setupConstraint
    private func setupConstraint() {
        contentView.addSubview(checkBoxImageView)
        checkBoxImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(11)
            $0.bottom.equalToSuperview().offset(-11)
            $0.size.equalTo(24)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkBoxImageView.snp.trailing).offset(16)
            $0.top.equalToSuperview().offset(11)
            $0.bottom.equalToSuperview().offset(-11)
        }
        
        contentView.addSubview(nextImageView)
        nextImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(11)
            $0.bottom.equalToSuperview().offset(-11)
            $0.size.equalTo(24)
        }
    }
    
    func updateState(isOn: Bool, animated: Bool = false) {
        UIView.transition(with: checkBoxImageView, duration: animated ? 0.2 : 0, options: .transitionCrossDissolve) {
            self.checkBoxImageView.image = isOn ? .checkboxFilled : .checkboxOutlined
        }
        UIView.animate(withDuration: animated ? animated ? 0.2 : 0 : 0) {
            self.nextImageView.tintColor = isOn ? .som.p300 : .som.gray500
        }
        UIView.transition(with: titleLabel, duration: animated ? 0.2 : 0, options: .transitionCrossDissolve) {
            self.titleLabel.textColor = isOn ? .som.p300 : .som.gray500
        }
    }
}
