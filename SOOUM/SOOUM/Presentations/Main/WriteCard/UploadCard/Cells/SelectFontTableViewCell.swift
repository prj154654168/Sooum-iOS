//
//  SelectFontTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift


class SelectFontTableViewCell: UITableViewCell {
    
    enum FontType {
        case gothic
        case handwriting
    }
    
    var selectedFont: BehaviorRelay<SelectFontTableViewCell.FontType>?
    
    var disposeBag = DisposeBag()

    let titleLabel = UILabel().then {
        $0.typography = .som.body1WithRegular
        $0.textAlignment = .center
        $0.textColor = .som.gray700
        $0.text = "글씨체"
    }
    
    let buttonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.distribution = .fillEqually
    }
    
    let gothicButtonLabel = UILabel().then {
        $0.typography = .som.body1WithBold
        $0.textAlignment = .center
        $0.textColor = .som.white
        $0.backgroundColor = .som.p300
        $0.text = "고딕체"
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }

    let handwritingButtonLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(type: .school, size: 18, weight: .bold),
            lineHeight: 18,
            letterSpacing: 0.05
         )
        $0.textAlignment = .center
        $0.textColor = .som.gray600
        $0.backgroundColor = .som.gray300
        $0.text = "손글씨체"
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    let seperatorView = UIView().then {
        $0.backgroundColor = .som.gray200
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - setData
    func setData(selectedFont: BehaviorRelay<SelectFontTableViewCell.FontType>) {
        self.selectedFont = selectedFont
        
        action()
    }
    
    // MARK: - action
    private func action() {
        gothicButtonLabel.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                object.updateFont(font: .gothic, animated: true)
            }
            .disposed(by: disposeBag)
        
        handwritingButtonLabel.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                object.updateFont(font: .handwriting, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateFont(font: FontType, animated: Bool) {
        self.selectedFont?.accept(font)
        let duration = animated ? 0.2 : 0.0
        
        UIView.animate(withDuration: duration) {
            self.gothicButtonLabel.backgroundColor = font == .gothic ? .som.p300 : .som.gray300
            self.handwritingButtonLabel.backgroundColor = font == .handwriting ? .som.p300 : .som.gray300
        }
        
        UIView.transition(
            with: self.gothicButtonLabel,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: {
                self.gothicButtonLabel.textColor = font == .gothic ? .som.white : .som.gray600
            },
            completion: nil
        )
        
        UIView.transition(
            with: self.handwritingButtonLabel,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: {
                self.handwritingButtonLabel.textColor = font == .handwriting ? .som.white : .som.gray600
            }, 
            completion: nil
        )
    }

    // MARK: - setupConstraint
    private func setupConstraint() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        contentView.addSubview(buttonStack)
        buttonStack.addArrangedSubviews(gothicButtonLabel, handwritingButtonLabel)
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        gothicButtonLabel.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        handwritingButtonLabel.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        contentView.addSubview(seperatorView)
        seperatorView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(4)
        }
    }
}
