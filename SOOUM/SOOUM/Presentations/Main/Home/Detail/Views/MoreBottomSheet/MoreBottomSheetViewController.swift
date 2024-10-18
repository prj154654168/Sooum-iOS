//
//  MoreBottomSheetViewController.swift
//  SOOUM
//
//  Created by 오현식 on 10/2/24.
//

import UIKit

import SnapKit
import Then


class MoreBottomSheetViewController: BaseViewController {
    
    enum Text {
        static let blockButtonTitle: String = "차단하기"
        static let reportButtonTitle: String = "신고하기"
    }
    
    let blockBackgroundButton = UIButton()
    private let blockLabel = UILabel().then {
        $0.text = Text.blockButtonTitle
        $0.textColor = .som.black
        $0.textAlignment = .center
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 16, weight: .medium),
            lineHeight: 29,
            letterSpacing: -0.04
        )
    }
    
    let reportBackgroundButton = UIButton()
    private let reportLabel = UILabel().then {
        $0.text = Text.reportButtonTitle
        $0.textColor = .som.black
        $0.textAlignment = .center
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 16, weight: .medium),
            lineHeight: 29,
            letterSpacing: -0.04
        )
    }
    
    override func setupConstraints() {
        
        self.view.backgroundColor = .som.white
        self.view.layer.cornerRadius = 20
        self.view.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(178 - 21)
        }
        
        let handle = UIView().then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .som.gray02
        }
        self.view.addSubview(handle)
        handle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(68)
            $0.height.equalTo(2)
        }
        
        let blockBackgroundView = UIView()
        self.view.addSubview(blockBackgroundView)
        blockBackgroundView.snp.makeConstraints {
            $0.top.equalTo(handle.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        blockBackgroundView.addSubview(self.blockLabel)
        self.blockLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        blockBackgroundView.addSubview(self.blockBackgroundButton)
        self.blockBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(self.blockLabel.snp.edges)
        }
        
        let reportBackgroundView = UIView()
        self.view.addSubview(reportBackgroundView)
        reportBackgroundView.snp.makeConstraints {
            $0.top.equalTo(blockBackgroundView.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        
        reportBackgroundView.addSubview(self.reportLabel)
        self.reportLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        reportBackgroundView.addSubview(self.reportBackgroundButton)
        self.reportBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(self.reportLabel.snp.edges)
        }
    }
}
