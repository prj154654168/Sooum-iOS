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
        $0.image = .init(.icon(.outlined(.checkBox)))
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .som.gray500
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
    }
    
    let nextButton = SOMButton().then {
        $0.image = .init(.icon(.outlined(.next)))
        $0.foregroundColor = .som.gray800
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
    
    func setData(
        state: Bool,
        term: TermsOfService
    ) {
        self.disposeBag = DisposeBag()
        self.term = term
        titleLabel.text = term.text
        updateState(isOn: state)
        
        nextButton.rx.tap
            .subscribe(with: self) { object, _ in
                if UIApplication.shared.canOpenURL(term.notionURL) {
                    UIApplication.shared.open(term.notionURL, options: [:], completionHandler: nil)
                }
            }
            .disposed(by: self.disposeBag)
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
        
        contentView.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(11)
            $0.bottom.equalToSuperview().offset(-11)
            $0.size.equalTo(24)
        }
    }
    
    func updateState(isOn: Bool, animated: Bool = false) {
        UIView.transition(with: checkBoxImageView, duration: animated ? 0.2 : 0, options: .transitionCrossDissolve) {
            self.checkBoxImageView.image = isOn ? .init(.icon(.filled(.checkBox))) : .init(.icon(.outlined(.checkBox)))
            self.checkBoxImageView.tintColor = isOn ? .som.p300 : .som.gray600
        }
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.nextButton.foregroundColor = isOn ? .som.p300 : .som.gray600
        }
        UIView.transition(with: titleLabel, duration: animated ? 0.2 : 0, options: .transitionCrossDissolve) {
            self.titleLabel.textColor = isOn ? .som.p300 : .som.gray600
        }
    }
}
