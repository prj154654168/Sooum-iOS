//
//  MakeVoteView.swift
//  SOOUM
//
//  Created by 오현식 on 6/14/26.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxGesture
import RxSwift

class MakeVoteView: UIView {
    
    enum Text {
        static let navigationTitle: String = "투표 만들기"
        static let navigationCompleteButtonTitle: String = "완료"
        
        static let makeVoteTextFieldPlaceholderText: String = "항목 입력"
        
        static let addVoteButtonTitle: String = "항목 추가"
    }
    
    
    // MARK: Views
    
    private lazy var closeButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.delete_full))))
        $0.foregroundColor = .som.v2.black
        
        $0.addTarget(
            self,
            action: #selector(self.closeButtonDidTapped(_:)),
            for: .touchUpInside
        )
    }
    
    private let titleLabel = UILabel().then {
        $0.text = Text.navigationTitle
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.title1
    }
    
    private lazy var completeButton = SOMButton().then {
        $0.title = Text.navigationCompleteButtonTitle
        $0.typography = .som.v2.subtitle1
        $0.foregroundColor = .som.v2.black
        
        $0.isEnabled = false
        
        $0.addTarget(
            self,
            action: #selector(self.completeButtonDidTapped(_:)),
            for: .touchUpInside
        )
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    private let firstVoteTextField = VoteTextField().then {
        $0.placeholder = Text.makeVoteTextFieldPlaceholderText
    }
    
    private let secondVoteTextField = VoteTextField().then {
        $0.placeholder = Text.makeVoteTextFieldPlaceholderText
    }
    
    private let thirdVoteContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 16
        
        $0.tag = 3
    }
    private let thirdVoteTextField = VoteTextField().then {
        $0.placeholder = Text.makeVoteTextFieldPlaceholderText
    }
    private lazy var removeThirdVoteTextFieldButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.remove_circle))))
        $0.foregroundColor = .som.v2.gray400
        
        $0.addTarget(
            self,
            action: #selector(self.removeThirdTextFieldButtonDidTapped(_:)),
            for: .touchUpInside
        )
    }
    
    private let fourthVoteContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 16
        
        $0.tag = 4
    }
    private let fourthVoteTextField = VoteTextField().then {
        $0.placeholder = Text.makeVoteTextFieldPlaceholderText
    }
    private lazy var removeFourthVoteTextFieldButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.remove_circle))))
        $0.foregroundColor = .som.v2.gray400
        
        $0.addTarget(
            self,
            action: #selector(self.removeFourtTextFieldButtonDidTapped(_:)),
            for: .touchUpInside
        )
    }
    
    private lazy var addVoteButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.plus))))
        
        $0.title = Text.addVoteButtonTitle
        $0.typography = .som.v2.subtitle1
        $0.foregroundColor = .som.v2.gray600
        $0.backgroundColor = .som.v2.white
        $0.inset = .init(top: 12, left: 16, bottom: 12, right: 16)
        
        $0.contentHorizontalAlignment = .center
        
        $0.isDashedBorderEnabled = true
        
        $0.addTarget(self, action: #selector(self.tap(_:)), for: .touchUpInside)
    }
    
    // MARK: Variables
    
    private var displayedVoteTextFieldCounts: Int = 2 {
        didSet {
            self.addVoteButton.isHidden = self.displayedVoteTextFieldCounts >= 4
        }
    }
    
    
    // MARK: Variables + Rx
    
    var makedVotes: [String] = ["", "", "", ""] {
        didSet {
            
        }
    }
    
    private var disposeBag = DisposeBag()
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupConstraints()
        self.bind()
        
        self.container.arrangedSubviews([firstVoteTextField, secondVoteTextField])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.5)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(self.completeButton)
        self.completeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(26.5)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.addSubview(self.addVoteButton)
        self.addVoteButton.snp.makeConstraints {
            $0.top.equalTo(self.container.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
    }
    
    private func bind() {
        
        self.firstVoteTextField.textField.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(with: self) { object, text in
                let trimedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                object.makedVotes[0] = trimedText
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Objc func
    
    @objc
    private func removeThirdTextFieldButtonDidTapped(_ button: UIButton) {
        self.container.arrangedSubviews.forEach { item in
            guard item.tag == 3 else { return }
            item.removeFromSuperview()
            self.displayedVoteTextFieldCounts -= 1
        }
    }
    
    @objc
    private func removeFourtTextFieldButtonDidTapped(_ button: UIButton) {
        self.container.arrangedSubviews.forEach { item in
            guard item.tag == 4 else { return }
            item.removeFromSuperview()
            self.displayedVoteTextFieldCounts -= 1
        }
    }
    
    @objc
    private func tap(_ button: UIButton) {
        switch self.displayedVoteTextFieldCounts {
        case 2:
            self.container.addArrangedSubview(thirdVoteContainer)
        case 3:
            self.container.addArrangedSubview(fourthVoteContainer)
        default:
            return
        }
        self.displayedVoteTextFieldCounts += 1
    }
    
    @objc
    private func closeButtonDidTapped(_ button: UIButton) {
        
    }
    
    @objc
    private func completeButtonDidTapped(_ button: UIButton) {
        
    }
}
