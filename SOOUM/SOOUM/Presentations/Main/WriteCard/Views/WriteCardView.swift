//
//  WriteCardView.swift
//  SOOUM
//
//  Created by 오현식 on 10/20/24.
//

import UIKit

import SnapKit
import Then


class WriteCardView: UIView {
    
    enum Text {
        static let writeCardPlaceholder: String = "이곳에 글을 적어주세요."
        static let wirteTagPlaceholder: String = "#태그를 입력해주세요!"
        static let relatedTagsTitle: String = "#관련태그"
    }
    
    lazy var writeCardTextView = WriteCardTextView().then {
        $0.maxCharacter = 1000
        $0.placeholder = Text.writeCardPlaceholder
    }
    
    lazy var writeTagTextField = WriteTagTextField().then {
        $0.placeholder = Text.wirteTagPlaceholder
    }
    
    let pungTimeView = PungTimeView().then {
        $0.isHidden = true
    }
    
    let writtenTags = SOMTags(configure: .horizontalWithRemove).then {
        $0.tag = 0
    }
    
    let relatedTagsBackgroundView = UIView().then {
        $0.isHidden = true
    }
    let relatedTags = SOMTags(configure: .verticalWithoutRemove).then {
        $0.tag = 1
    }
    
    var writtenTagsHeightConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.addSubview(self.writeCardTextView)
        self.writeCardTextView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.addSubview(self.writtenTags)
        self.writtenTags.snp.makeConstraints {
            $0.top.equalTo(self.writeCardTextView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            self.writtenTagsHeightConstraint = $0.height.equalTo(12).constraint
        }
        
        self.addSubview(self.writeTagTextField)
        self.writeTagTextField.snp.makeConstraints {
            $0.top.equalTo(self.writtenTags.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.addSubview(self.pungTimeView)
        self.pungTimeView.snp.makeConstraints {
            $0.top.equalTo(self.writtenTags.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(25)
        }
        
        self.addSubview(self.relatedTagsBackgroundView)
        self.relatedTagsBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.writeTagTextField.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        let relatedTagsLabel = UILabel().then {
            $0.text = Text.relatedTagsTitle
            $0.textColor = UIColor(hex: "#303030")
            $0.textAlignment = .center
            $0.typography = .som.body2WithBold
        }
        self.relatedTagsBackgroundView.addSubview(relatedTagsLabel)
        relatedTagsLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        self.relatedTagsBackgroundView.addSubview(self.relatedTags)
        self.relatedTags.snp.makeConstraints {
            $0.top.equalTo(relatedTagsLabel.snp.bottom).offset(8)
            $0.bottom.leading.trailing.equalToSuperview()
            let height: CGFloat = 32 * 3 + 12 * 2
            $0.height.equalTo(height)
        }
    }
}
