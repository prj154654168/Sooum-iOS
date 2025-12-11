//
//  WriteCardView.swift
//  SOOUM
//
//  Created by 오현식 on 10/20/24.
//

import UIKit

import SnapKit
import Then

import RxCocoa

class WriteCardView: UIView {
    
    enum Text {
        static let writeCardPlaceholder: String = "숨에서 편하게 이야기 나눠요"
        static let wirteTagPlaceholder: String = "태그 추가"
    }
    
    
    // MARK: Views
    
    lazy var writeCardTextView = WriteCardTextView().then {
        $0.placeholder = Text.writeCardPlaceholder
        $0.delegate = self
    }
    
    lazy var writeCardTags = WriteCardTags().then {
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    var textViewDidBeginEditing = PublishRelay<Void>()
    var textFieldDidBeginEditing = PublishRelay<Void>()
    var textDidChanged = BehaviorRelay<String?>(value: nil)
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.writeCardTextView)
        self.writeCardTextView.snp.makeConstraints {
            $0.verticalEdges.centerX.equalToSuperview()
            let width: CGFloat = UIScreen.main.bounds.width - 16 * 2
            $0.size.equalTo(width)
        }
        
        self.writeCardTextView.addSubview(self.writeCardTags)
        self.writeCardTags.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(1)
            $0.trailing.equalToSuperview().offset(-1)
            $0.height.equalTo(28)
        }
    }
}

extension WriteCardView: WritrCardTextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: WriteCardTextView) {
        self.textViewDidBeginEditing.accept(())
    }
}


extension WriteCardView: WriteCardTagsDelegate {
    
    func textFieldDidBeginEditing(_ textField: WriteCardTagFooter) {
        self.textFieldDidBeginEditing.accept(())
    }
    
    func textDidChanged(_ text: String?) {
        self.textDidChanged.accept(text)
    }
}
