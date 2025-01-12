//
//  PungTimeView.swift
//  SOOUM
//
//  Created by 오현식 on 12/30/24.
//

import UIKit

import SnapKit
import Then


class PungTimeView: UIView {
    
    enum Text {
        static let pungTimeGuideMessage: String = "이후에 카드가 삭제될 예정이에요"
    }
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .som.p300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let pungTimeLabel = UILabel().then {
        $0.textColor = .som.white
        $0.typography = .som.body2WithBold
    }
    
    private let pungTimeGuideLabel = UILabel().then {
        $0.text = Text.pungTimeGuideMessage
        $0.textColor = .som.gray700
        $0.typography = .som.body2WithBold
    }
    
    var text: String? {
        set {
            self.pungTimeLabel.text = newValue
        }
        get {
            return self.pungTimeLabel.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        
        self.backgroundView.addSubview(self.pungTimeLabel)
        self.pungTimeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        self.addSubview(self.pungTimeGuideLabel)
        self.pungTimeGuideLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.backgroundView.snp.trailing).offset(3)
            $0.trailing.equalToSuperview()
        }
    }
}
