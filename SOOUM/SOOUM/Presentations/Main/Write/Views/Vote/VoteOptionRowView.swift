//
//  VoteOptionRowView.swift
//  SOOUM
//
//  Created by 오현식 on 6/27/26.
//

import UIKit

import SnapKit
import Then

final class VoteOptionRowView: UIView {
    
    enum Constants {
        static let removeButtonSize: CGFloat = 24
    }
    
    
    // MARK: Views
    
    private let textFieldView = VoteTextField()
    
    private lazy var removeButton = UIButton().then {
        $0.addTarget(self, action: #selector(self.removeButtonDidTapped(_:)), for: .touchUpInside)
    }
    private let removeImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.remove_circle))))
        $0.tintColor = .som.v2.gray400
        $0.contentMode = .scaleAspectFit
    }
    
    
    // MARK: Variables
    
    var onTextChanged: ((String) -> Void)?
    var onRemoveTapped: (() -> Void)?
    
    
    // MARK: Initialize
    
    init(
        text: String,
        placeholder: String,
        showsRemoveButton: Bool
    ) {
        super.init(frame: .zero)
        self.setupConstraints(showsRemoveButton: showsRemoveButton)
        self.textFieldView.placeholder = placeholder
        self.textFieldView.text = text
        self.removeButton.isHidden = showsRemoveButton == false
        self.textFieldView.textField.addTarget(
            self,
            action: #selector(self.textFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints(showsRemoveButton: Bool) {
        self.addSubview(self.textFieldView)
        self.textFieldView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(
                showsRemoveButton
                ? -(Constants.removeButtonSize + 16)
                : .zero
            )
        }
        
        guard showsRemoveButton else { return }
        
        self.addSubview(self.removeButton)
        self.removeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.size.equalTo(Constants.removeButtonSize)
        }
        
        self.removeButton.addSubview(self.removeImageView)
        self.removeImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Constants.removeButtonSize)
        }
    }
    
    
    // MARK: Objc func
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        self.onTextChanged?(textField.text ?? "")
    }
    
    @objc
    private func removeButtonDidTapped(_ button: UIButton) {
        self.onRemoveTapped?()
    }
}
