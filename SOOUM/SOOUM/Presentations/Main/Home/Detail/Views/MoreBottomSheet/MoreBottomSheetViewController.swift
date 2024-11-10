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
    
    let blockLabelButton = UIButton().then {
        let typography = Typography.som.body1WithBold
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        attributes.updateValue(UIColor.som.red, forKey: .foregroundColor)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(
            Text.blockButtonTitle,
            attributes: AttributeContainer(attributes)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer(attributes)
        }
        config.contentInsets = .zero
        $0.configuration = config
    }
    
    let reportLabelButton = UIButton().then {
        let typography = Typography.som.body1WithBold
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        attributes.updateValue(UIColor.som.red, forKey: .foregroundColor)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(
            Text.reportButtonTitle,
            attributes: AttributeContainer(attributes)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer(attributes)
        }
        config.contentInsets = .zero
        $0.configuration = config
    }
    
    override func setupConstraints() {
        
        self.view.backgroundColor = .som.white
        
        let handle = UIView().then {
            $0.backgroundColor = UIColor(hex: "#B4B4B4")
            $0.layer.cornerRadius = 8
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
        blockBackgroundView.addSubview(self.blockLabelButton)
        self.blockLabelButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        let reportBackgroundView = UIView()
        self.view.addSubview(reportBackgroundView)
        reportBackgroundView.snp.makeConstraints {
            $0.top.equalTo(blockBackgroundView.snp.bottom)
            $0.bottom.equalToSuperview().offset(-21 )
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        reportBackgroundView.addSubview(self.reportLabelButton)
        self.reportLabelButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
