//
//  TagSearchTextFieldView.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

import ReactorKit
import RxGesture
import RxSwift

import SnapKit
import Then

class TagSearchTextFieldView: UIView {
    
    private let disposeBag = DisposeBag()
    
    let textField = UITextField().then {
        $0.textColor = .som.black
        $0.typography = .som.body2WithBold
        $0.placeholder = "태그 키워드를 입력해주세요"
    }
    
    let magnifyingGlassImageView = UIImageView().then {
        $0.image = .magnifyingglassOutlined
        $0.tintColor = .som.gray500
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        setupConstraints()
        action()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupConstraints
    private func setupConstraints() {
        self.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        self.addSubview(textField)
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        self.addSubview(magnifyingGlassImageView)
        magnifyingGlassImageView.snp.makeConstraints {
            $0.leading.equalTo(textField.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
    
    private func action() {
        self.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                object.textField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)
    }
    
}
